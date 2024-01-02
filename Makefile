OUTDIR?=.

SRCS:=$(wildcard *.s)
OBJ:=$(SRCS:%.s=$(OUTDIR)/%.out)
BINS:=$(OBJ:%.out=%.bin)

CC?=riscv32-unknown-elf

all: ${OBJ} ${BINS}

$(OUTDIR)/%.out: %.s
	$(CC)-gcc -march=rv32i -mabi=ilp32 -ffreestanding -nostartfiles -nostdlib -nodefaultlibs -Wl,-T,linker.ld -o $@ $<    

$(OUTDIR)/%.bin: $(OUTDIR)/%.out
	$(CC)-objcopy -O binary $< $@

clean:
	@rm $(OUTDIR)/*.bin $(OUTDIR)/*.out