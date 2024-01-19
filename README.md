# Design of a RISC-V microprocessor

## Testing

Run `make test` to run unit tests.

### Dependencies

- `nvc` compiler & simulator

To run the end-to-end tests, run the following commands:

```
cd tools
./run-tests.sh
```

#### Dependencies

- gnu-base-utils
- fd

To run arbitrary programs written in C or Assembly, use the `insert-program.sh` tool in the `tools` directory.
