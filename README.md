<!-- File generated from README.template.md -->

<div align="center">
  <img style="height: 18em"
       alt="Ribbon Language Logo"
       src="https://ribbon-lang.github.io/images/logo_full.svg"
       />
</div>

<div align="right">
  <h1>Ribbon<sup>I</sup></h1>
  <h3>The Ribbon Virtual Machine</h3>
  <sup>v0.0.0</sup>
</div>

---

This is a virtual machine implementation for the Ribbon programming language. This
project is still in the very early development stages. For now, issues are
turned off and pull requests without prior [discussion](#discussion) are
discouraged.


## Contents

+ [Discussion](#discussion)
+ [Usage](#usage)
    - [Building from source](#building-from-source)
        * [Zig Build Commands](#zig-build-commands)
        * [Zig Build Options](#zig-build-options)
    - [Inclusion as a library](#inclusion-as-a-library)
        * [From Zig](#from-zig)
        * [From C](#from-c)
        * [From other languages](#from-other-languages)
    - [CLI](#cli)
+ [ISA](#isa)
    - [High Level Properties](#high-level-properties)
    - [Parameter Legend](#parameter-legend)
    - [Op Codes](#op-codes)
        * [Basic](#basic)
        * [Control Flow](#control-flow)
        * [Memory](#memory)
        * [Arithmetic](#arithmetic)
        * [Boolean](#boolean)
        * [Size Cast Int](#size-cast-int)
        * [Size Cast Float](#size-cast-float)
        * [Int <-> Float Cast](#int---float-cast)


## Discussion

Eventually I will create some places for public discourse about the language,
for now you can reach me via:
- Email: noxabellus@gmail.com
- Discord DM, or on various dev servers: my username is `noxabellus`


## Usage

### Building from source

You will need [`zig`](https://ziglang.org/); likely, a nightly build.
The latest version known to work is `0.14.0-dev.1417+242d268a0`.

You can either:
+ Get it through [ZVM](https://www.zvm.app/) or [Zigup](https://marler8997.github.io/zigup/) (Recommended)
+ [Download it directly](https://ziglang.org/download)
+ Get the nightly build through a script like [night.zig](https://github.com/jsomedon/night.zig/)

#### Zig Build Commands
There are several commands available for `zig build` that can be run in usual fashion (i.e. `zig build run`):
| Command | Description |
|-|-|
|`run`| Build and run a quick debug test version of ribboni only (No headers, readme, lib ...) |
|`quick`| Build a quick debug test version of ribboni only (No headers, readme, lib ...) |
|`full`| Runs the following commands: test, readme, header |
|`verify`| Runs the following commands: verify-readme, verify-header, verify-tests |
|`check`| Run semantic analysis on all files referenced by a unit test; do not build artifacts (Useful with `zls` build on save) |
|`release`| Build the release versions of RibbonI for all targets |
|`unit-tests`| Run unit tests |
|`cli-tests`| Run cli tests |
|`c-tests`| Run C tests |
|`test`| Runs the following commands: unit-tests, cli-tests, c-tests |
|`readme`| Generate `./README.md` |
|`header`| Generate `./include/ribboni.h` |
|`verify-readme`| Verify that `./README.md` is up to date |
|`verify-header`| Verify that `./include/ribboni.h` is up to date |
|`verify-tests`| Verify that all tests pass (this is an alias for `test`) |


Running `zig build` alone will build with the designated or default target and optimization levels.

See `zig build --help` for more information.

#### Zig Build Options
In addition to typical zig build options, the build script supports the following options (though not all apply to every step):
| Option | Description | Default |
|-|-|-|
|`-DlogLevel=<log.Level>`| Logging output level to display |`.err`|
|`-DlogScopes=<string>`| Logging scopes to display |`ribboni`|
|`-DuseEmoji=<bool>`| Use emoji in the output |`true`|
|`-DuseAnsiStyles=<bool>`| Use ANSI styles in the output |`true`|
|`-DmaximumInlining=<bool>`| Try to inline as much as possible in the interpreter |`false`|
|`-DforceNewSnapshot=<bool>`| (Tests) Force a new snapshot to be created instead of referring to an existing one |`false`|
|`-DstripDebugInfo=<?bool>`| Override for optimization-specific settings for stripping debug info from the binary |`{ 110, 117, 108, 108 }`|


See `zig build --help` for more information.

### Inclusion as a library

#### From Zig

1. Include RibbonI in your `build.zig.zon` in the `.dependencies` section,
   either by linking the tar, `zig fetch`, or provide a local path to the source.
2. Add RibbonI to your module imports like this:
```zig
const ribbon_i = b.dependency("ribbon-i", .{
    // these should always be passed to ensure ribbon is built correctly
    .target = target,
    .optimize = optimize,

    // additional options can be passed here, these are the same as the build options
    // i.e.
    // .logLevel = .info,
});
module.addImport("RibbonI", ribbon_i.module("Core"));
```
3. See [`src/bin/ribboni.zig`](src/bin/ribboni.zig) for usage

#### From C

Should be straight forward, though the API is limited as of now.
Use the included header file, then link your program with the `.lib`/`.a` file.

#### From other languages

If your host language has C FFI, it should be fairly straight forward. If you make a binding for another language, please [let me know](#discussion) and I will link it here.


### CLI

The `ribboni` executable is a work in progress, but offers a functional command line interface for RibbonI.

#### CLI Usage
```
ribboni [--use-emoji <bool>] [--use-ansi-styles <bool>] <path>...
```
```
ribboni --help
```
```
ribboni --version
```

#### CLI Options
| Option | Description |
|-|-|
|`--help`| Display options help message, and exit |
|`--version`| Display SemVer2 version number for RibbonI, and exit |
|`--use-emoji <bool>`| Use emoji in the output [Default: true] |
|`--use-ansi-styles <bool>`| Use ANSI styles in the output [Default: true] |
|`<path>...`| Files to execute |


## ISA

The instruction set architecture for RibbonI is still in flux,
but here is a preliminary rundown.


### High level properties

+ Little-endian encoding
+ Separated address spaces for global data, executable, and working memory
+ Heap access controlled by host environment
+ 14-bit index x 16-bit address spaces for global data
+ Floating point values are IEEE754
+ Floats are fixed width, in sizes `32` and `64`
+ Integers are always two's complement
+ Integers are fixed width, in sizes `8`, `16`, `32`, and `64`
+ Sign of integers is not a property of types; only instructions
+ Structured control flow
+ Effects-aware
+ Tail recursion

### Parameter Legend

| Symbol | Type | Description | Bit Size |
|-|-|-|-|
| `O` | `Operand` | a register or a global index paired with an offset into it | `32` |
| `I` | `Index` (Varies) | a static index, varying kinds based on context (ie. `BlockIndex`, `HandlerSetIndex`, etc) | `16` |
| `[x]` | A variable-length array of `x` | a set of parameters; for example, the set of argument registers to provide to a function call | `8 + bits(x) * length` |


### Op codes

> [!note]
> Github markdown formatting is a bit weird;
> If you see scroll bars on the tables below, try reloading the page


#### Basic
<table>
    <tr>
        <th colspan="3" align="left" width="100%">trap<img width="960px" height="1" align="right"></th>
        <td>Params</td>
    </tr>
    <tr>
        <td colspan="3" width="100%" align="center">triggers a trap if execution reaches it</td>
        <td>None</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x00</code></td>
        <td align="left" width="1%"><code>trap</code></td>
        <td align="center" colspan="2">trigger a trap</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">nop<img width="960px" height="1" align="right"></th>
        <td>Params</td>
    </tr>
    <tr>
        <td colspan="3" width="100%" align="center">no operation, does nothing</td>
        <td>None</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x01</code></td>
        <td align="left" width="1%"><code>nop</code></td>
        <td align="center" colspan="2">no operation</td>
    </tr>
</table>

#### Control Flow
<table>
    <tr>
        <th colspan="3" align="left" width="100%">when_nz<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">if the 8-bit condition in <code>x</code> is non-zero:<br>enter the block designated by <code>b</code><br><br><code>b</code> is an absolute block index</td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr><tr><td>x</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x02</code></td>
        <td align="left" width="1%"><code>when_nz</code></td>
        <td align="center" colspan="3">one-way conditional block, based on the predicate being non-zero</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">when_z<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">if the 8-bit condition in <code>x</code> is zero:<br>enter the block designated by <code>b</code><br><br><code>b</code> is an absolute block index</td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr><tr><td>x</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x03</code></td>
        <td align="left" width="1%"><code>when_z</code></td>
        <td align="center" colspan="3">one-way conditional block, based on the predicate being zero</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">re<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="2" width="100%" align="center">restart the block designated by <code>b</code><br><br><code>b</code> is a relative block index<br>the designated block may not produce a value</td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x04</code></td>
        <td align="left" width="1%"><code>re</code></td>
        <td align="center" colspan="3">unconditional branch to start of block</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">re_nz<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">if the 8-bit condition in <code>x</code> is non-zero:<br>restart the block designated by <code>b</code><br><br><code>b</code> is a relative block index<br><br>the designated block may not produce a value</td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr><tr><td>x</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x05</code></td>
        <td align="left" width="1%"><code>re_nz</code></td>
        <td align="center" colspan="3">conditional branch to start of block, based on the predicate being non-zero</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">re_z<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">if the 8-bit condition in <code>x</code> is zero:<br>restart the block designated by <code>b</code><br><br><code>b</code> is a relative block index<br><br>the designated block may not produce a value</td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr><tr><td>x</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x06</code></td>
        <td align="left" width="1%"><code>re_z</code></td>
        <td align="center" colspan="3">conditional branch to start of block, based on the predicate being zero</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">call<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">call the function statically designated by <code>f</code><br>use the values designated by <code>as</code> as arguments<br><br>for <code>_v</code>, place the result in <code>y</code></td>
    </tr>
    <tr><td>f</td><td><code>I</code></td></tr><tr><td>as</td><td><code>[O]</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x07</code></td>
        <td align="left" width="1%"><code>call</code></td>
        <td align="center" colspan="3">static function call</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x08</code></td>
        <td align="left" width="1%"><code>call_v</code></td>
        <td align="center" colspan="3">static function call with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">tail_call<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">call the function statically designated by <code>f</code><br>use the values designated by <code>as</code> as arguments<br>end the current function<br><br>for <code>_v</code>, place the result in the caller's return register</td>
    </tr>
    <tr><td>f</td><td><code>I</code></td></tr><tr><td>as</td><td><code>[O]</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td colspan="2">None</td></tr>
    <tr>
        <td align="right" width="1%"><code>0x09</code></td>
        <td align="left" width="1%"><code>tail_call</code></td>
        <td align="center" colspan="3">static function tail call</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x0a</code></td>
        <td align="left" width="1%"><code>tail_call_v</code></td>
        <td align="center" colspan="3">static function tail call with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">prompt<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">prompt the evidence designated by <code>e</code><br>use the values designated by <code>as</code> as arguments<br><br>for <code>_v</code>, place the result in <code>y</code></td>
    </tr>
    <tr><td>e</td><td><code>I</code></td></tr><tr><td>as</td><td><code>[O]</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x0b</code></td>
        <td align="left" width="1%"><code>prompt</code></td>
        <td align="center" colspan="3">dynamically bound effect handler call</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x0c</code></td>
        <td align="left" width="1%"><code>prompt_v</code></td>
        <td align="center" colspan="3">dynamically bound effect handler call with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">tail_prompt<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">prompt the evidence designated by <code>e</code><br>use the values designated by <code>as</code> as arguments<br>end the current function<br><br>for <code>_v</code>, place the result in the caller's return register</td>
    </tr>
    <tr><td>e</td><td><code>I</code></td></tr><tr><td>as</td><td><code>[O]</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td colspan="2">None</td></tr>
    <tr>
        <td align="right" width="1%"><code>0x0d</code></td>
        <td align="left" width="1%"><code>tail_prompt</code></td>
        <td align="center" colspan="3">dynamically bound effect handler tail call</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x0e</code></td>
        <td align="left" width="1%"><code>tail_prompt_v</code></td>
        <td align="center" colspan="3">dynamically bound effect handler tail call with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">dyn_call<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">call the function at the index stored in <code>f</code><br>use the values designated by <code>as</code> as arguments<br><br>for <code>_v</code>, place the result in <code>y</code></td>
    </tr>
    <tr><td>f</td><td><code>O</code></td></tr><tr><td>as</td><td><code>[O]</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x0f</code></td>
        <td align="left" width="1%"><code>dyn_call</code></td>
        <td align="center" colspan="3">dynamic function call</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x10</code></td>
        <td align="left" width="1%"><code>dyn_call_v</code></td>
        <td align="center" colspan="3">dynamic function call with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">dyn_tail_call<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">call the function at the index stored in <code>f</code><br>use the values designated by <code>as</code> as arguments<br>end the current function<br><br>for <code>_v</code>, place the result in the caller's return register</td>
    </tr>
    <tr><td>f</td><td><code>O</code></td></tr><tr><td>as</td><td><code>[O]</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td colspan="2">None</td></tr>
    <tr>
        <td align="right" width="1%"><code>0x11</code></td>
        <td align="left" width="1%"><code>dyn_tail_call</code></td>
        <td align="center" colspan="3">dynamic function tail call</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x12</code></td>
        <td align="left" width="1%"><code>dyn_tail_call_v</code></td>
        <td align="center" colspan="3">dynamic function tail call with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">ret<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">return control from the current function<br><br>for <code>_v</code>, place the result designated by <code>y</code> into the call's return register</td>
    </tr>
    <tr><td colspan="2">None</td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x13</code></td>
        <td align="left" width="1%"><code>ret</code></td>
        <td align="center" colspan="3">function return</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x14</code></td>
        <td align="left" width="1%"><code>ret_v</code></td>
        <td align="center" colspan="3">function return with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">term<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">terminate the current handler's with block<br><br>for <code>_v</code>,  place the result designated by <code>y</code> into the handler's return register</td>
    </tr>
    <tr><td colspan="2">None</td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x15</code></td>
        <td align="left" width="1%"><code>term</code></td>
        <td align="center" colspan="3">effect handler termination</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x16</code></td>
        <td align="left" width="1%"><code>term_v</code></td>
        <td align="center" colspan="3">effect handler termination with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">block<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">enter the block designated by <code>b</code><br><br><code>b</code> is an absolute block index<br><br>for <code>_v</code>, place the result of the block in <code>y</code></td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x17</code></td>
        <td align="left" width="1%"><code>block</code></td>
        <td align="center" colspan="3">basic block</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x18</code></td>
        <td align="left" width="1%"><code>block_v</code></td>
        <td align="center" colspan="3">basic block with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">with<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">enter the block designated by <code>b</code><br>use the effect handler set designated by <code>h</code> to handle effects<br><br><code>b</code> is an absolute block index<br><br>for <code>_v</code>, place the result of the block in <code>y</code></td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr><tr><td>h</td><td><code>I</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x19</code></td>
        <td align="left" width="1%"><code>with</code></td>
        <td align="center" colspan="3">effect handler block</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x1a</code></td>
        <td align="left" width="1%"><code>with_v</code></td>
        <td align="center" colspan="3">effect handler block with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">if_nz<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="6" width="100%" align="center">if the 8-bit condition in <code>x</code> is non-zero:<br>then: enter the block designated by <code>t</code><br>else: enter the block designated by <code>e</code><br><br><code>t</code> and <code>e</code> are absolute block indices<br><br>for <code>_v</code>, place the result of the block in <code>y</code></td>
    </tr>
    <tr><td>t</td><td><code>I</code></td></tr><tr><td>e</td><td><code>I</code></td></tr><tr><td>x</td><td><code>O</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x1b</code></td>
        <td align="left" width="1%"><code>if_nz</code></td>
        <td align="center" colspan="3">two-way conditional block, based on the predicate being non-zero</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x1c</code></td>
        <td align="left" width="1%"><code>if_nz_v</code></td>
        <td align="center" colspan="3">two-way conditional block, based on the predicate being non-zero with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">if_z<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="6" width="100%" align="center">if the 8-bit condition in <code>x</code> is zero:<br>then: enter the block designated by <code>t</code><br>else: enter the block designated by <code>e</code><br><br><code>t</code> and <code>e</code> are absolute block indices<br><br>for <code>_v</code>, place the result of the block in <code>y</code></td>
    </tr>
    <tr><td>t</td><td><code>I</code></td></tr><tr><td>e</td><td><code>I</code></td></tr><tr><td>x</td><td><code>O</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x1d</code></td>
        <td align="left" width="1%"><code>if_z</code></td>
        <td align="center" colspan="3">two-way conditional block, based on the predicate being zero</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x1e</code></td>
        <td align="left" width="1%"><code>if_z_v</code></td>
        <td align="center" colspan="3">two-way conditional block, based on the predicate being zero with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">case<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">indexed by the 8-bit value in <code>x</code>:<br>enter one of the blocks designated in <code>bs</code><br><br>each value of <code>bs</code> is an absolute block index<br><br>for <code>_v</code>, place the result of the block in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>bs</td><td><code>[I]</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x1f</code></td>
        <td align="left" width="1%"><code>case</code></td>
        <td align="center" colspan="3">jump table</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x20</code></td>
        <td align="left" width="1%"><code>case_v</code></td>
        <td align="center" colspan="3">jump table with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">br<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">exit the block designated by <code>b</code><br><br><code>b</code> is a relative block index<br><br>for <code>_v</code>, copy the value in <code>y</code> into the block's yield register</td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x21</code></td>
        <td align="left" width="1%"><code>br</code></td>
        <td align="center" colspan="3">unconditional branch out of block</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x22</code></td>
        <td align="left" width="1%"><code>br_v</code></td>
        <td align="center" colspan="3">unconditional branch out of block with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">br_nz<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">if the 8-bit condition in <code>x</code> is non-zero:<br>exit the block designated by <code>b</code><br><br><code>b</code> is a relative block index<br><br>for <code>_v</code>, copy the value in <code>y</code> into the block's yield register</td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr><tr><td>x</td><td><code>O</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x23</code></td>
        <td align="left" width="1%"><code>br_nz</code></td>
        <td align="center" colspan="3">conditional branch out of block, based on the predicate being non-zero</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x24</code></td>
        <td align="left" width="1%"><code>br_nz_v</code></td>
        <td align="center" colspan="3">conditional branch out of block, based on the predicate being non-zero with a result value</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">br_z<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params&nbsp;(both)</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="5" width="100%" align="center">if the 8-bit condition in <code>x</code> is zero:<br>exit the block designated by <code>b</code><br><br><code>b</code> is a relative block index<br><br>for <code>_v</code>, copy the value in <code>y</code> into the block's yield register</td>
    </tr>
    <tr><td>b</td><td><code>I</code></td></tr><tr><td>x</td><td><code>O</code></td></tr>
    <tr>
        <td colspan="2">Params&nbsp;(_v)</td>
    </tr>
    <tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x25</code></td>
        <td align="left" width="1%"><code>br_z</code></td>
        <td align="center" colspan="3">conditional branch out of block, based on the predicate being zero</td>
    </tr>
    <tr>
        <td align="right" width="1%"><code>0x26</code></td>
        <td align="left" width="1%"><code>br_z_v</code></td>
        <td align="center" colspan="3">conditional branch out of block, based on the predicate being zero with a result value</td>
    </tr>
</table>

#### Memory
<table>
    <tr>
        <th colspan="3" align="left" width="100%">addr<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">copy the address of <code>x</code> into <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0x27</code></td>
        <td align="left" width="1%"><code>addr</code></td>
        <td align="center" colspan="3">address extraction of operand</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">load<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">copy <em>n</em> aligned bits from the address stored in <code>x</code> into <code>y</code><br>the address must be located in the operand stack or global memory</td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x28</code></td><td align="left" width="1%"><code>load8</code></td><td align="center" colspan="3">8 bit read from address</td></tr><tr><td align="right" width="1%"><code>0x29</code></td><td align="left" width="1%"><code>load16</code></td><td align="center" colspan="3">16 bit read from address</td></tr><tr><td align="right" width="1%"><code>0x2a</code></td><td align="left" width="1%"><code>load32</code></td><td align="center" colspan="3">32 bit read from address</td></tr><tr><td align="right" width="1%"><code>0x2b</code></td><td align="left" width="1%"><code>load64</code></td><td align="center" colspan="3">64 bit read from address</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">store<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">copy <em>n</em> aligned bits from <code>x</code> to the address stored in <code>y</code><br>the address must be located in the operand stack or global memory</td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x2c</code></td><td align="left" width="1%"><code>store8</code></td><td align="center" colspan="3">8 bit write to address</td></tr><tr><td align="right" width="1%"><code>0x2d</code></td><td align="left" width="1%"><code>store16</code></td><td align="center" colspan="3">16 bit write to address</td></tr><tr><td align="right" width="1%"><code>0x2e</code></td><td align="left" width="1%"><code>store32</code></td><td align="center" colspan="3">32 bit write to address</td></tr><tr><td align="right" width="1%"><code>0x2f</code></td><td align="left" width="1%"><code>store64</code></td><td align="center" colspan="3">64 bit write to address</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">clear<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="2" width="100%" align="center">clear <em>n</em> aligned bits of <code>x</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x30</code></td><td align="left" width="1%"><code>clear8</code></td><td align="center" colspan="3">8 bit zeroing</td></tr><tr><td align="right" width="1%"><code>0x31</code></td><td align="left" width="1%"><code>clear16</code></td><td align="center" colspan="3">16 bit zeroing</td></tr><tr><td align="right" width="1%"><code>0x32</code></td><td align="left" width="1%"><code>clear32</code></td><td align="center" colspan="3">32 bit zeroing</td></tr><tr><td align="right" width="1%"><code>0x33</code></td><td align="left" width="1%"><code>clear64</code></td><td align="center" colspan="3">64 bit zeroing</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">swap<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">swap <em>n</em> aligned bits stored in <code>x</code> and <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x34</code></td><td align="left" width="1%"><code>swap8</code></td><td align="center" colspan="3">8 bit value swap</td></tr><tr><td align="right" width="1%"><code>0x35</code></td><td align="left" width="1%"><code>swap16</code></td><td align="center" colspan="3">16 bit value swap</td></tr><tr><td align="right" width="1%"><code>0x36</code></td><td align="left" width="1%"><code>swap32</code></td><td align="center" colspan="3">32 bit value swap</td></tr><tr><td align="right" width="1%"><code>0x37</code></td><td align="left" width="1%"><code>swap64</code></td><td align="center" colspan="3">64 bit value swap</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">copy<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">copy <em>n</em> aligned bits from <code>x</code> into <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x38</code></td><td align="left" width="1%"><code>copy8</code></td><td align="center" colspan="3">8 bit value copy</td></tr><tr><td align="right" width="1%"><code>0x39</code></td><td align="left" width="1%"><code>copy16</code></td><td align="center" colspan="3">16 bit value copy</td></tr><tr><td align="right" width="1%"><code>0x3a</code></td><td align="left" width="1%"><code>copy32</code></td><td align="center" colspan="3">32 bit value copy</td></tr><tr><td align="right" width="1%"><code>0x3b</code></td><td align="left" width="1%"><code>copy64</code></td><td align="center" colspan="3">64 bit value copy</td></tr>
</table>

#### Arithmetic
<table>
    <tr>
        <th colspan="3" align="left" width="100%">add<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>addition</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x3c</code></td><td align="left" width="1%"><code>i_add8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer addition</td></tr><tr><td align="right" width="1%"><code>0x3d</code></td><td align="left" width="1%"><code>i_add16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer addition</td></tr><tr><td align="right" width="1%"><code>0x3e</code></td><td align="left" width="1%"><code>i_add32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer addition</td></tr><tr><td align="right" width="1%"><code>0x3f</code></td><td align="left" width="1%"><code>i_add64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer addition</td></tr> <tr><td align="right" width="1%"><code>0x40</code></td><td align="left" width="1%"><code>f_add32</code></td><td align="center" colspan="3">32 bit floating point addition</td></tr><tr><td align="right" width="1%"><code>0x41</code></td><td align="left" width="1%"><code>f_add64</code></td><td align="center" colspan="3">64 bit floating point addition</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">sub<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>subtraction</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x42</code></td><td align="left" width="1%"><code>i_sub8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer subtraction</td></tr><tr><td align="right" width="1%"><code>0x43</code></td><td align="left" width="1%"><code>i_sub16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer subtraction</td></tr><tr><td align="right" width="1%"><code>0x44</code></td><td align="left" width="1%"><code>i_sub32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer subtraction</td></tr><tr><td align="right" width="1%"><code>0x45</code></td><td align="left" width="1%"><code>i_sub64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer subtraction</td></tr> <tr><td align="right" width="1%"><code>0x46</code></td><td align="left" width="1%"><code>f_sub32</code></td><td align="center" colspan="3">32 bit floating point subtraction</td></tr><tr><td align="right" width="1%"><code>0x47</code></td><td align="left" width="1%"><code>f_sub64</code></td><td align="center" colspan="3">64 bit floating point subtraction</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">mul<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>multiplication</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x48</code></td><td align="left" width="1%"><code>i_mul8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer multiplication</td></tr><tr><td align="right" width="1%"><code>0x49</code></td><td align="left" width="1%"><code>i_mul16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer multiplication</td></tr><tr><td align="right" width="1%"><code>0x4a</code></td><td align="left" width="1%"><code>i_mul32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer multiplication</td></tr><tr><td align="right" width="1%"><code>0x4b</code></td><td align="left" width="1%"><code>i_mul64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer multiplication</td></tr> <tr><td align="right" width="1%"><code>0x4c</code></td><td align="left" width="1%"><code>f_mul32</code></td><td align="center" colspan="3">32 bit floating point multiplication</td></tr><tr><td align="right" width="1%"><code>0x4d</code></td><td align="left" width="1%"><code>f_mul64</code></td><td align="center" colspan="3">64 bit floating point multiplication</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">div<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>division</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x4e</code></td><td align="left" width="1%"><code>u_div8</code></td><td align="center" colspan="3">8 bit unsigned integer division</td></tr><tr><td align="right" width="1%"><code>0x4f</code></td><td align="left" width="1%"><code>s_div8</code></td><td align="center" colspan="3">8 bit signed integer division</td></tr><tr><td align="right" width="1%"><code>0x50</code></td><td align="left" width="1%"><code>u_div16</code></td><td align="center" colspan="3">16 bit unsigned integer division</td></tr><tr><td align="right" width="1%"><code>0x51</code></td><td align="left" width="1%"><code>s_div16</code></td><td align="center" colspan="3">16 bit signed integer division</td></tr><tr><td align="right" width="1%"><code>0x52</code></td><td align="left" width="1%"><code>u_div32</code></td><td align="center" colspan="3">32 bit unsigned integer division</td></tr><tr><td align="right" width="1%"><code>0x53</code></td><td align="left" width="1%"><code>s_div32</code></td><td align="center" colspan="3">32 bit signed integer division</td></tr><tr><td align="right" width="1%"><code>0x54</code></td><td align="left" width="1%"><code>u_div64</code></td><td align="center" colspan="3">64 bit unsigned integer division</td></tr><tr><td align="right" width="1%"><code>0x55</code></td><td align="left" width="1%"><code>s_div64</code></td><td align="center" colspan="3">64 bit signed integer division</td></tr> <tr><td align="right" width="1%"><code>0x56</code></td><td align="left" width="1%"><code>f_div32</code></td><td align="center" colspan="3">32 bit floating point division</td></tr><tr><td align="right" width="1%"><code>0x57</code></td><td align="left" width="1%"><code>f_div64</code></td><td align="center" colspan="3">64 bit floating point division</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">rem<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>remainder division</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x58</code></td><td align="left" width="1%"><code>u_rem8</code></td><td align="center" colspan="3">8 bit unsigned integer remainder division</td></tr><tr><td align="right" width="1%"><code>0x59</code></td><td align="left" width="1%"><code>s_rem8</code></td><td align="center" colspan="3">8 bit signed integer remainder division</td></tr><tr><td align="right" width="1%"><code>0x5a</code></td><td align="left" width="1%"><code>u_rem16</code></td><td align="center" colspan="3">16 bit unsigned integer remainder division</td></tr><tr><td align="right" width="1%"><code>0x5b</code></td><td align="left" width="1%"><code>s_rem16</code></td><td align="center" colspan="3">16 bit signed integer remainder division</td></tr><tr><td align="right" width="1%"><code>0x5c</code></td><td align="left" width="1%"><code>u_rem32</code></td><td align="center" colspan="3">32 bit unsigned integer remainder division</td></tr><tr><td align="right" width="1%"><code>0x5d</code></td><td align="left" width="1%"><code>s_rem32</code></td><td align="center" colspan="3">32 bit signed integer remainder division</td></tr><tr><td align="right" width="1%"><code>0x5e</code></td><td align="left" width="1%"><code>u_rem64</code></td><td align="center" colspan="3">64 bit unsigned integer remainder division</td></tr><tr><td align="right" width="1%"><code>0x5f</code></td><td align="left" width="1%"><code>s_rem64</code></td><td align="center" colspan="3">64 bit signed integer remainder division</td></tr> <tr><td align="right" width="1%"><code>0x60</code></td><td align="left" width="1%"><code>f_rem32</code></td><td align="center" colspan="3">32 bit floating point remainder division</td></tr><tr><td align="right" width="1%"><code>0x61</code></td><td align="left" width="1%"><code>f_rem64</code></td><td align="center" colspan="3">64 bit floating point remainder division</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">neg<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">perform <em>negation</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x62</code></td><td align="left" width="1%"><code>s_neg8</code></td><td align="center" colspan="3">8 bit signed integer negation</td></tr><tr><td align="right" width="1%"><code>0x63</code></td><td align="left" width="1%"><code>s_neg16</code></td><td align="center" colspan="3">16 bit signed integer negation</td></tr><tr><td align="right" width="1%"><code>0x64</code></td><td align="left" width="1%"><code>s_neg32</code></td><td align="center" colspan="3">32 bit signed integer negation</td></tr><tr><td align="right" width="1%"><code>0x65</code></td><td align="left" width="1%"><code>s_neg64</code></td><td align="center" colspan="3">64 bit signed integer negation</td></tr> <tr><td align="right" width="1%"><code>0x66</code></td><td align="left" width="1%"><code>f_neg32</code></td><td align="center" colspan="3">32 bit floating point negation</td></tr><tr><td align="right" width="1%"><code>0x67</code></td><td align="left" width="1%"><code>f_neg64</code></td><td align="center" colspan="3">64 bit floating point negation</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">bitnot<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">perform <em>bitwise not</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x68</code></td><td align="left" width="1%"><code>i_bitnot8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer bitwise not</td></tr><tr><td align="right" width="1%"><code>0x69</code></td><td align="left" width="1%"><code>i_bitnot16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer bitwise not</td></tr><tr><td align="right" width="1%"><code>0x6a</code></td><td align="left" width="1%"><code>i_bitnot32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer bitwise not</td></tr><tr><td align="right" width="1%"><code>0x6b</code></td><td align="left" width="1%"><code>i_bitnot64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer bitwise not</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">bitand<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>bitwise and</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x6c</code></td><td align="left" width="1%"><code>i_bitand8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer bitwise and</td></tr><tr><td align="right" width="1%"><code>0x6d</code></td><td align="left" width="1%"><code>i_bitand16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer bitwise and</td></tr><tr><td align="right" width="1%"><code>0x6e</code></td><td align="left" width="1%"><code>i_bitand32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer bitwise and</td></tr><tr><td align="right" width="1%"><code>0x6f</code></td><td align="left" width="1%"><code>i_bitand64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer bitwise and</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">bitor<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>bitwise or</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x70</code></td><td align="left" width="1%"><code>i_bitor8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer bitwise or</td></tr><tr><td align="right" width="1%"><code>0x71</code></td><td align="left" width="1%"><code>i_bitor16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer bitwise or</td></tr><tr><td align="right" width="1%"><code>0x72</code></td><td align="left" width="1%"><code>i_bitor32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer bitwise or</td></tr><tr><td align="right" width="1%"><code>0x73</code></td><td align="left" width="1%"><code>i_bitor64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer bitwise or</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">bitxor<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>bitwise xor</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x74</code></td><td align="left" width="1%"><code>i_bitxor8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer bitwise exclusive or</td></tr><tr><td align="right" width="1%"><code>0x75</code></td><td align="left" width="1%"><code>i_bitxor16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer bitwise exclusive or</td></tr><tr><td align="right" width="1%"><code>0x76</code></td><td align="left" width="1%"><code>i_bitxor32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer bitwise exclusive or</td></tr><tr><td align="right" width="1%"><code>0x77</code></td><td align="left" width="1%"><code>i_bitxor64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer bitwise exclusive or</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">shiftl<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>bitwise left shift</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x78</code></td><td align="left" width="1%"><code>i_shiftl8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer left shift</td></tr><tr><td align="right" width="1%"><code>0x79</code></td><td align="left" width="1%"><code>i_shiftl16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer left shift</td></tr><tr><td align="right" width="1%"><code>0x7a</code></td><td align="left" width="1%"><code>i_shiftl32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer left shift</td></tr><tr><td align="right" width="1%"><code>0x7b</code></td><td align="left" width="1%"><code>i_shiftl64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer left shift</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">shiftr<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>bitwise right shift</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x7c</code></td><td align="left" width="1%"><code>u_shiftr8</code></td><td align="center" colspan="3">8 bit logical right shift</td></tr><tr><td align="right" width="1%"><code>0x7d</code></td><td align="left" width="1%"><code>s_shiftr8</code></td><td align="center" colspan="3">8 bit arithmetic right shift</td></tr><tr><td align="right" width="1%"><code>0x7e</code></td><td align="left" width="1%"><code>u_shiftr16</code></td><td align="center" colspan="3">16 bit logical right shift</td></tr><tr><td align="right" width="1%"><code>0x7f</code></td><td align="left" width="1%"><code>s_shiftr16</code></td><td align="center" colspan="3">16 bit arithmetic right shift</td></tr><tr><td align="right" width="1%"><code>0x80</code></td><td align="left" width="1%"><code>u_shiftr32</code></td><td align="center" colspan="3">32 bit logical right shift</td></tr><tr><td align="right" width="1%"><code>0x81</code></td><td align="left" width="1%"><code>s_shiftr32</code></td><td align="center" colspan="3">32 bit arithmetic right shift</td></tr><tr><td align="right" width="1%"><code>0x82</code></td><td align="left" width="1%"><code>u_shiftr64</code></td><td align="center" colspan="3">64 bit logical right shift</td></tr><tr><td align="right" width="1%"><code>0x83</code></td><td align="left" width="1%"><code>s_shiftr64</code></td><td align="center" colspan="3">64 bit arithmetic right shift</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">eq<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>equality comparison</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x84</code></td><td align="left" width="1%"><code>i_eq8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer equality comparison</td></tr><tr><td align="right" width="1%"><code>0x85</code></td><td align="left" width="1%"><code>i_eq16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer equality comparison</td></tr><tr><td align="right" width="1%"><code>0x86</code></td><td align="left" width="1%"><code>i_eq32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer equality comparison</td></tr><tr><td align="right" width="1%"><code>0x87</code></td><td align="left" width="1%"><code>i_eq64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer equality comparison</td></tr> <tr><td align="right" width="1%"><code>0x88</code></td><td align="left" width="1%"><code>f_eq32</code></td><td align="center" colspan="3">32 bit floating point equality comparison</td></tr><tr><td align="right" width="1%"><code>0x89</code></td><td align="left" width="1%"><code>f_eq64</code></td><td align="center" colspan="3">64 bit floating point equality comparison</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">ne<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>inequality comparison</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x8a</code></td><td align="left" width="1%"><code>i_ne8</code></td><td align="center" colspan="3">8 bit sign-agnostic integer inequality comparison</td></tr><tr><td align="right" width="1%"><code>0x8b</code></td><td align="left" width="1%"><code>i_ne16</code></td><td align="center" colspan="3">16 bit sign-agnostic integer inequality comparison</td></tr><tr><td align="right" width="1%"><code>0x8c</code></td><td align="left" width="1%"><code>i_ne32</code></td><td align="center" colspan="3">32 bit sign-agnostic integer inequality comparison</td></tr><tr><td align="right" width="1%"><code>0x8d</code></td><td align="left" width="1%"><code>i_ne64</code></td><td align="center" colspan="3">64 bit sign-agnostic integer inequality comparison</td></tr> <tr><td align="right" width="1%"><code>0x8e</code></td><td align="left" width="1%"><code>f_ne32</code></td><td align="center" colspan="3">32 bit floating point inequality comparison</td></tr><tr><td align="right" width="1%"><code>0x8f</code></td><td align="left" width="1%"><code>f_ne64</code></td><td align="center" colspan="3">64 bit floating point inequality comparison</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">lt<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>less than comparison</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x90</code></td><td align="left" width="1%"><code>u_lt8</code></td><td align="center" colspan="3">8 bit unsigned integer less than comparison</td></tr><tr><td align="right" width="1%"><code>0x91</code></td><td align="left" width="1%"><code>s_lt8</code></td><td align="center" colspan="3">8 bit signed integer less than comparison</td></tr><tr><td align="right" width="1%"><code>0x92</code></td><td align="left" width="1%"><code>u_lt16</code></td><td align="center" colspan="3">16 bit unsigned integer less than comparison</td></tr><tr><td align="right" width="1%"><code>0x93</code></td><td align="left" width="1%"><code>s_lt16</code></td><td align="center" colspan="3">16 bit signed integer less than comparison</td></tr><tr><td align="right" width="1%"><code>0x94</code></td><td align="left" width="1%"><code>u_lt32</code></td><td align="center" colspan="3">32 bit unsigned integer less than comparison</td></tr><tr><td align="right" width="1%"><code>0x95</code></td><td align="left" width="1%"><code>s_lt32</code></td><td align="center" colspan="3">32 bit signed integer less than comparison</td></tr><tr><td align="right" width="1%"><code>0x96</code></td><td align="left" width="1%"><code>u_lt64</code></td><td align="center" colspan="3">64 bit unsigned integer less than comparison</td></tr><tr><td align="right" width="1%"><code>0x97</code></td><td align="left" width="1%"><code>s_lt64</code></td><td align="center" colspan="3">64 bit signed integer less than comparison</td></tr> <tr><td align="right" width="1%"><code>0x98</code></td><td align="left" width="1%"><code>f_lt32</code></td><td align="center" colspan="3">32 bit floating point less than comparison</td></tr><tr><td align="right" width="1%"><code>0x99</code></td><td align="left" width="1%"><code>f_lt64</code></td><td align="center" colspan="3">64 bit floating point less than comparison</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">le<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>less than or equal comparison</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0x9a</code></td><td align="left" width="1%"><code>u_le8</code></td><td align="center" colspan="3">8 bit unsigned integer less than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0x9b</code></td><td align="left" width="1%"><code>s_le8</code></td><td align="center" colspan="3">8 bit signed integer less than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0x9c</code></td><td align="left" width="1%"><code>u_le16</code></td><td align="center" colspan="3">16 bit unsigned integer less than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0x9d</code></td><td align="left" width="1%"><code>s_le16</code></td><td align="center" colspan="3">16 bit signed integer less than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0x9e</code></td><td align="left" width="1%"><code>u_le32</code></td><td align="center" colspan="3">32 bit unsigned integer less than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0x9f</code></td><td align="left" width="1%"><code>s_le32</code></td><td align="center" colspan="3">32 bit signed integer less than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xa0</code></td><td align="left" width="1%"><code>u_le64</code></td><td align="center" colspan="3">64 bit unsigned integer less than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xa1</code></td><td align="left" width="1%"><code>s_le64</code></td><td align="center" colspan="3">64 bit signed integer less than or equal comparison</td></tr> <tr><td align="right" width="1%"><code>0xa2</code></td><td align="left" width="1%"><code>f_le32</code></td><td align="center" colspan="3">32 bit floating point less than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xa3</code></td><td align="left" width="1%"><code>f_le64</code></td><td align="center" colspan="3">64 bit floating point less than or equal comparison</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">gt<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>greater than comparison</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0xa4</code></td><td align="left" width="1%"><code>u_gt8</code></td><td align="center" colspan="3">8 bit unsigned integer greater than comparison</td></tr><tr><td align="right" width="1%"><code>0xa5</code></td><td align="left" width="1%"><code>s_gt8</code></td><td align="center" colspan="3">8 bit signed integer greater than comparison</td></tr><tr><td align="right" width="1%"><code>0xa6</code></td><td align="left" width="1%"><code>u_gt16</code></td><td align="center" colspan="3">16 bit unsigned integer greater than comparison</td></tr><tr><td align="right" width="1%"><code>0xa7</code></td><td align="left" width="1%"><code>s_gt16</code></td><td align="center" colspan="3">16 bit signed integer greater than comparison</td></tr><tr><td align="right" width="1%"><code>0xa8</code></td><td align="left" width="1%"><code>u_gt32</code></td><td align="center" colspan="3">32 bit unsigned integer greater than comparison</td></tr><tr><td align="right" width="1%"><code>0xa9</code></td><td align="left" width="1%"><code>s_gt32</code></td><td align="center" colspan="3">32 bit signed integer greater than comparison</td></tr><tr><td align="right" width="1%"><code>0xaa</code></td><td align="left" width="1%"><code>u_gt64</code></td><td align="center" colspan="3">64 bit unsigned integer greater than comparison</td></tr><tr><td align="right" width="1%"><code>0xab</code></td><td align="left" width="1%"><code>s_gt64</code></td><td align="center" colspan="3">64 bit signed integer greater than comparison</td></tr> <tr><td align="right" width="1%"><code>0xac</code></td><td align="left" width="1%"><code>f_gt32</code></td><td align="center" colspan="3">32 bit floating point greater than comparison</td></tr><tr><td align="right" width="1%"><code>0xad</code></td><td align="left" width="1%"><code>f_gt64</code></td><td align="center" colspan="3">64 bit floating point greater than comparison</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">ge<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>greater than or equal comparison</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0xae</code></td><td align="left" width="1%"><code>u_ge8</code></td><td align="center" colspan="3">8 bit unsigned integer greater than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xaf</code></td><td align="left" width="1%"><code>s_ge8</code></td><td align="center" colspan="3">8 bit signed integer greater than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xb0</code></td><td align="left" width="1%"><code>u_ge16</code></td><td align="center" colspan="3">16 bit unsigned integer greater than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xb1</code></td><td align="left" width="1%"><code>s_ge16</code></td><td align="center" colspan="3">16 bit signed integer greater than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xb2</code></td><td align="left" width="1%"><code>u_ge32</code></td><td align="center" colspan="3">32 bit unsigned integer greater than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xb3</code></td><td align="left" width="1%"><code>s_ge32</code></td><td align="center" colspan="3">32 bit signed integer greater than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xb4</code></td><td align="left" width="1%"><code>u_ge64</code></td><td align="center" colspan="3">64 bit unsigned integer greater than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xb5</code></td><td align="left" width="1%"><code>s_ge64</code></td><td align="center" colspan="3">64 bit signed integer greater than or equal comparison</td></tr> <tr><td align="right" width="1%"><code>0xb6</code></td><td align="left" width="1%"><code>f_ge32</code></td><td align="center" colspan="3">32 bit floating point greater than or equal comparison</td></tr><tr><td align="right" width="1%"><code>0xb7</code></td><td align="left" width="1%"><code>f_ge64</code></td><td align="center" colspan="3">64 bit floating point greater than or equal comparison</td></tr>
</table>

#### Boolean
<table>
    <tr>
        <th colspan="3" align="left" width="100%">b_and<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>logical and</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0xb8</code></td>
        <td align="left" width="1%"><code>b_and</code></td>
        <td align="center" colspan="3">logical and</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">b_or<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="4" width="100%" align="center">perform <em>logical or</em> on the values designated by <code>x</code> and <code>y</code><br>store the result in <code>z</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr><tr><td>z</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0xb9</code></td>
        <td align="left" width="1%"><code>b_or</code></td>
        <td align="center" colspan="3">logical or</td>
    </tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">b_not<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">perform <em>logical not</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr>
        <td align="right" width="1%"><code>0xba</code></td>
        <td align="left" width="1%"><code>b_not</code></td>
        <td align="center" colspan="3">logical not</td>
    </tr>
</table>

#### Size Cast Int
<table>
    <tr>
        <th colspan="3" align="left" width="100%">u_ext<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">perform <em>integer zero-extension</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0xbb</code></td><td align="left" width="1%"><code>u_ext8x16</code></td><td align="center" colspan="3">8 bit to 16 bit unsigned integer extension</td></tr><tr><td align="right" width="1%"><code>0xbc</code></td><td align="left" width="1%"><code>u_ext8x32</code></td><td align="center" colspan="3">8 bit to 32 bit unsigned integer extension</td></tr><tr><td align="right" width="1%"><code>0xbd</code></td><td align="left" width="1%"><code>u_ext8x64</code></td><td align="center" colspan="3">8 bit to 64 bit unsigned integer extension</td></tr><tr><td align="right" width="1%"><code>0xbe</code></td><td align="left" width="1%"><code>u_ext16x32</code></td><td align="center" colspan="3">16 bit to 32 bit unsigned integer extension</td></tr><tr><td align="right" width="1%"><code>0xbf</code></td><td align="left" width="1%"><code>u_ext16x64</code></td><td align="center" colspan="3">16 bit to 64 bit unsigned integer extension</td></tr><tr><td align="right" width="1%"><code>0xc0</code></td><td align="left" width="1%"><code>u_ext32x64</code></td><td align="center" colspan="3">32 bit to 64 bit unsigned integer extension</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">s_ext<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">perform <em>integer sign-extension</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0xc1</code></td><td align="left" width="1%"><code>s_ext8x16</code></td><td align="center" colspan="3">8 bit to 16 bit signed integer extension</td></tr><tr><td align="right" width="1%"><code>0xc2</code></td><td align="left" width="1%"><code>s_ext8x32</code></td><td align="center" colspan="3">8 bit to 32 bit signed integer extension</td></tr><tr><td align="right" width="1%"><code>0xc3</code></td><td align="left" width="1%"><code>s_ext8x64</code></td><td align="center" colspan="3">8 bit to 64 bit signed integer extension</td></tr><tr><td align="right" width="1%"><code>0xc4</code></td><td align="left" width="1%"><code>s_ext16x32</code></td><td align="center" colspan="3">16 bit to 32 bit signed integer extension</td></tr><tr><td align="right" width="1%"><code>0xc5</code></td><td align="left" width="1%"><code>s_ext16x64</code></td><td align="center" colspan="3">16 bit to 64 bit signed integer extension</td></tr><tr><td align="right" width="1%"><code>0xc6</code></td><td align="left" width="1%"><code>s_ext32x64</code></td><td align="center" colspan="3">32 bit to 64 bit signed integer extension</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">i_trunc<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">perform <em>integer truncation</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0xc7</code></td><td align="left" width="1%"><code>i_trunc64x32</code></td><td align="center" colspan="3">64 bit to 32 bit sign-agnostic integer truncation</td></tr><tr><td align="right" width="1%"><code>0xc8</code></td><td align="left" width="1%"><code>i_trunc64x16</code></td><td align="center" colspan="3">64 bit to 16 bit sign-agnostic integer truncation</td></tr><tr><td align="right" width="1%"><code>0xc9</code></td><td align="left" width="1%"><code>i_trunc64x8</code></td><td align="center" colspan="3">64 bit to 8 bit sign-agnostic integer truncation</td></tr><tr><td align="right" width="1%"><code>0xca</code></td><td align="left" width="1%"><code>i_trunc32x16</code></td><td align="center" colspan="3">32 bit to 16 bit sign-agnostic integer truncation</td></tr><tr><td align="right" width="1%"><code>0xcb</code></td><td align="left" width="1%"><code>i_trunc32x8</code></td><td align="center" colspan="3">32 bit to 8 bit sign-agnostic integer truncation</td></tr><tr><td align="right" width="1%"><code>0xcc</code></td><td align="left" width="1%"><code>i_trunc16x8</code></td><td align="center" colspan="3">16 bit to 8 bit sign-agnostic integer truncation</td></tr>
</table>

#### Size Cast Float
<table>
    <tr>
        <th colspan="3" align="left" width="100%">f_ext<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">perform <em>floating point extension</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0xcd</code></td><td align="left" width="1%"><code>f_ext32x64</code></td><td align="center" colspan="3">32 bit to 64 bit floating point extension</td></tr>
</table>
<table>
    <tr>
        <th colspan="3" align="left" width="100%">f_trunc<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" width="100%" align="center">perform <em>floating point truncation</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0xce</code></td><td align="left" width="1%"><code>f_trunc64x32</code></td><td align="center" colspan="3">64 bit to 32 bit floating point truncation</td></tr>
</table>

#### Int <-> Float Cast
<table>
    <tr>
        <th colspan="3" align="left" width="100%">a_to_b<img width="960px" height="1" align="right"></th>
        <td colspan="2">Params</td>
    </tr>
    <tr>
        <td colspan="3" rowspan="3" align="center">perform <em>int <-> float conversion</em> on the value designated by <code>x</code><br>store the result in <code>y</code></td>
    </tr>
    <tr><td>x</td><td><code>O</code></td></tr><tr><td>y</td><td><code>O</code></td></tr>
    <tr><td align="right" width="1%"><code>0xcf</code></td><td align="left" width="1%"><code>u8_to_f32</code></td><td align="center" colspan="3">8 bit unsigned integer to 32 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xcf</code></td><td align="left" width="1%"><code>f32_to_u8</code></td><td align="center" colspan="3">32 bit floating point to 8 bit unsigned integer conversion</td></tr><tr><td align="right" width="1%"><code>0xd1</code></td><td align="left" width="1%"><code>u8_to_f64</code></td><td align="center" colspan="3">8 bit unsigned integer to 64 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xd1</code></td><td align="left" width="1%"><code>f64_to_u8</code></td><td align="center" colspan="3">64 bit floating point to 8 bit unsigned integer conversion</td></tr><tr><td align="right" width="1%"><code>0xd3</code></td><td align="left" width="1%"><code>u16_to_f32</code></td><td align="center" colspan="3">16 bit unsigned integer to 32 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xd3</code></td><td align="left" width="1%"><code>f32_to_u16</code></td><td align="center" colspan="3">32 bit floating point to 16 bit unsigned integer conversion</td></tr><tr><td align="right" width="1%"><code>0xd5</code></td><td align="left" width="1%"><code>u16_to_f64</code></td><td align="center" colspan="3">16 bit unsigned integer to 64 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xd5</code></td><td align="left" width="1%"><code>f64_to_u16</code></td><td align="center" colspan="3">64 bit floating point to 16 bit unsigned integer conversion</td></tr><tr><td align="right" width="1%"><code>0xd7</code></td><td align="left" width="1%"><code>u32_to_f32</code></td><td align="center" colspan="3">32 bit unsigned integer to 32 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xd7</code></td><td align="left" width="1%"><code>f32_to_u32</code></td><td align="center" colspan="3">32 bit floating point to 32 bit unsigned integer conversion</td></tr><tr><td align="right" width="1%"><code>0xd9</code></td><td align="left" width="1%"><code>u32_to_f64</code></td><td align="center" colspan="3">32 bit unsigned integer to 64 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xd9</code></td><td align="left" width="1%"><code>f64_to_u32</code></td><td align="center" colspan="3">64 bit floating point to 32 bit unsigned integer conversion</td></tr><tr><td align="right" width="1%"><code>0xdb</code></td><td align="left" width="1%"><code>u64_to_f32</code></td><td align="center" colspan="3">64 bit unsigned integer to 32 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xdb</code></td><td align="left" width="1%"><code>f32_to_u64</code></td><td align="center" colspan="3">32 bit floating point to 64 bit unsigned integer conversion</td></tr><tr><td align="right" width="1%"><code>0xdd</code></td><td align="left" width="1%"><code>u64_to_f64</code></td><td align="center" colspan="3">64 bit unsigned integer to 64 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xdd</code></td><td align="left" width="1%"><code>f64_to_u64</code></td><td align="center" colspan="3">64 bit floating point to 64 bit unsigned integer conversion</td></tr><tr><td align="right" width="1%"><code>0xdf</code></td><td align="left" width="1%"><code>s8_to_f32</code></td><td align="center" colspan="3">8 bit signed integer to 32 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xdf</code></td><td align="left" width="1%"><code>f32_to_s8</code></td><td align="center" colspan="3">32 bit floating point to 8 bit signed integer conversion</td></tr><tr><td align="right" width="1%"><code>0xe1</code></td><td align="left" width="1%"><code>s8_to_f64</code></td><td align="center" colspan="3">8 bit signed integer to 64 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xe1</code></td><td align="left" width="1%"><code>f64_to_s8</code></td><td align="center" colspan="3">64 bit floating point to 8 bit signed integer conversion</td></tr><tr><td align="right" width="1%"><code>0xe3</code></td><td align="left" width="1%"><code>s16_to_f32</code></td><td align="center" colspan="3">16 bit signed integer to 32 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xe3</code></td><td align="left" width="1%"><code>f32_to_s16</code></td><td align="center" colspan="3">32 bit floating point to 16 bit signed integer conversion</td></tr><tr><td align="right" width="1%"><code>0xe5</code></td><td align="left" width="1%"><code>s16_to_f64</code></td><td align="center" colspan="3">16 bit signed integer to 64 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xe5</code></td><td align="left" width="1%"><code>f64_to_s16</code></td><td align="center" colspan="3">64 bit floating point to 16 bit signed integer conversion</td></tr><tr><td align="right" width="1%"><code>0xe7</code></td><td align="left" width="1%"><code>s32_to_f32</code></td><td align="center" colspan="3">32 bit signed integer to 32 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xe7</code></td><td align="left" width="1%"><code>f32_to_s32</code></td><td align="center" colspan="3">32 bit floating point to 32 bit signed integer conversion</td></tr><tr><td align="right" width="1%"><code>0xe9</code></td><td align="left" width="1%"><code>s32_to_f64</code></td><td align="center" colspan="3">32 bit signed integer to 64 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xe9</code></td><td align="left" width="1%"><code>f64_to_s32</code></td><td align="center" colspan="3">64 bit floating point to 32 bit signed integer conversion</td></tr><tr><td align="right" width="1%"><code>0xeb</code></td><td align="left" width="1%"><code>s64_to_f32</code></td><td align="center" colspan="3">64 bit signed integer to 32 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xeb</code></td><td align="left" width="1%"><code>f32_to_s64</code></td><td align="center" colspan="3">32 bit floating point to 64 bit signed integer conversion</td></tr><tr><td align="right" width="1%"><code>0xed</code></td><td align="left" width="1%"><code>s64_to_f64</code></td><td align="center" colspan="3">64 bit signed integer to 64 bit floating point conversion</td></tr><tr><td align="right" width="1%"><code>0xed</code></td><td align="left" width="1%"><code>f64_to_s64</code></td><td align="center" colspan="3">64 bit floating point to 64 bit signed integer conversion</td></tr>
</table>

