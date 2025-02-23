import parse, sys

function = parse.compile('{addr:x} <{func:w}>\n')
jcc = parse.compile('{:w}\t${}<{:w}+{:x}>')

with open(sys.argv[1], 'r') as fd:
    asm = fd.readlines()

with open(sys.argv[1] + '.bak', 'w') as fd:
    fd.write('\n'.join(asm))

func_addr = {
    parsed['func']: parsed['addr']
        for line in asm
    if (parsed := function.parse(line)) is not None
}

for i in range(len(asm)):
    parsed = jcc.search(asm[i])
    if parsed:
        j, _, func, offset = parsed.fixed
        if func in func_addr:
            line = asm[i].split("\t;")[0]
            asm[i] = f'{line}\t; {j} to {(func_addr[func] + offset):04x}\n'

with open(sys.argv[1], 'w') as fd:
    fd.write(''.join(asm))
