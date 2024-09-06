pub const std = @import("std");

const Core = @import("root.zig");
const ISA = Core.ISA;
const Endian = Core.Endian;

const Writer = @This();

inner: std.io.AnyWriter,
endian: std.builtin.Endian = ISA.ENDIANNESS,

pub fn init(inner: std.io.AnyWriter) Writer {
    return .{
        .inner = inner,
    };
}

pub fn initEndian(inner: std.io.AnyWriter, endian: std.builtin.Endian) Writer {
    return .{
        .inner = inner,
        .endian = endian,
    };
}

pub fn writeByte(self: Writer, value: u8) !void {
    try self.inner.writeByte(value);
}

pub fn writeBytes(self: Writer, values: []u8) !void {
    try self.inner.writeAll(values);
}

pub fn writeRaw(self: Writer, value: anytype) !void {
    const T = @TypeOf(value);
    const size = @sizeOf(T);

    const buffer = @as([*]u8, @ptrCast(&value))[0..size];

    try self.inner.writeAll(buffer);
}

pub fn write(self: Writer, value: anytype) !void {
    const T = @TypeOf(value);

    if (T == void) return;

    if (comptime std.meta.hasFn(T, "write")) {
        return T.write(self, value);
    }

    if (comptime Endian.IntType(T)) |I| {
        return self.inner.writeInt(I, Endian.bitCastTo(value), self.endian);
    } else {
        return self.writeStructure(value);
    }
}

fn writeStructure(self: Writer, value: anytype) !void {
    const T = @TypeOf(value);
    switch (@typeInfo(T)) {
        // handled by write:
        // .void

        // handled by Endian.IntType:
        // .int => T,
        // .vector => std.meta.Int(.unsigned, @sizeOf(T) * 8),

        // .float => |info| std.meta.Int(.unsigned, info.bits),

        // .@"struct" => |info|
        //     if (info.backing_integer) |i| i
        //     else null,

        // .@"enum" => |info| IntType(info.tag_type),

        .@"struct" => |info| {
            inline for (info.fields) |field| {
                const fieldValue = @field(value, field.name);
                try self.write(fieldValue);
            }

            return;
        },

        .@"union" => |info| if (info.tag_type) |TT| {
            const tag = @as(TT, value);

            try self.write(tag);

            inline for (info.fields) |field| {
                if (tag == @field(TT, field.name)) {
                    const fieldValue = @field(value, field.name);
                    try self.write(fieldValue);
                    return;
                }
            }

            unreachable;
        } else
            @compileError(std.fmt.comptimePrint("cannot read union `{s}` without tag type", .{
                @typeName(T),
            })),

        .array => |info| {
            for (0..info.len) |i| {
                const element = @field(value, i);
                try self.write(element);
            }

            return;
        },

        .pointer => |info| switch (info.size) {
            .One => {
                return self.write(value.*);
            },
            .Many => if (info.sentinel) |sPtr| {
                const sentinel = @as(*const info.child, @ptrCast(sPtr)).*;

                for (value) |element| {
                    try self.write(element);
                }

                return self.write(sentinel);
            } else
                @compileError(std.fmt.comptimePrint("cannot write pointer `{s}` with kind Many, requires sentinel", .{
                    @typeName(T),
                })),
            .Slice => {
                const len = value.len;
                try self.write(len);

                for (value) |element| {
                    try self.write(element);
                }

                if (info.sentinel) |sPtr| {
                    const sentinel = @as(*const info.child, @ptrCast(sPtr)).*;
                    try self.write(sentinel);
                }

                return;
            },
            else =>
                @compileError(std.fmt.comptimePrint("cannot write pointer `{s}` with kind {s}", .{
                    @typeName(T),
                    info.size,
                }))
        },

        else =>
            @compileError(std.fmt.comptimePrint("cannot write type `{s}` with type info: {}", .{
                @typeName(T),
                @typeInfo(T),
            }))
    }

    unreachable;
}
