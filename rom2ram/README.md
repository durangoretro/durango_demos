# ROM-to-RAM demo

## Description

A simple example of the way to assemble code into ROM _that will be copied to and exectuted from **RAM** instead_. Useful for code dealing with **ShadowRAM** and ROM _bankswitching_.

### Function

An infinite loop filling the screen with every byte value each time, in RGB-colour mode.

### Build

`xa rom2ram.s` will create a 16 KiB ROM file. No other options are needed or accepted.

You may, however, add the `-l` option to create a _labels file_, in case you want to inspect the assigned addresses.

### Usage

Code will instantly copy into RAM (from `$0800`) and execute forever, with the Error LED turned _off_ as usual. Hitting `NMI` will freeze the computer, keeping the LED off. Hit `RESET` to recover.

## Source code analysis

Two different sections are to be considered: the **bootloader** (executed within ROM space) which copies the _payload_ into RAM; and the **payload** itself, assembled to be executed from its _copy_ into RAM.

### Labels

- `reset:` usual 6502 init, plus Durango·X minimal setup.
- `copy:` **bootloader** loop to copy the _payload_ into RAM. For this little payload, _absolute indexed_ addressing is enough, configured by the previous `LDX #`. You may want to use _zeropage-indirect post-indexed_ for larger payloads, but the principle is the same; make sure your _source_ pointer is set for the ROM-included copy, and the _destination_ is set for the required RAM address.
- `bootend:` the end of _bootloader_. This will **never** be reached because of the previous `JMP $0800` which launches the payload copy on RAM. You may do some other stuff _before_ launching the payload copy _on RAM_, but make sure you don't run into the _payload section **into ROM**_.
- `c_start:` marks the beginning of the **payload**, as seen from the _**ROM** addressing space_. Same as the above in this simple example.
- `dest:` **start of payload** into the _**RAM** addressing space_, as set by the `* =` operator above.
- `page` and `loop` are internal labels for the payload. These won't be visible outside the `.(` and `.)` operators for convenience, but that ocultation is not needed.
- `d_end:` is the **end of the payload**, still within RAM addressing space.

After that, PC is reset once again thru the `* =` operator, now back into _**ROM** addressing space_. Then a suitable filling plus the usual ROM footer is used:

- `irq:` dummy IRQ handler (does nothing)
- `nmi:` NMI handler (locks the computer)
