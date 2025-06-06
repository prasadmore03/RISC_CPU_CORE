import argparse

# Define opcode and register mappings for our RISC CPU with 16 registers
OPCODES = {
    'ADD': '1010', 
    'SUB': '1011', 
    'DIV': '1100', 
    'STM': '0001',
    'LDM': '0000', 
    'LDR': '0010', 
    'MOV': '0011', 
    'AND': '0100',
    'OR': '0101', 
    'XOR': '0110', 
    'SHL': '1000',
    'SHR': '1001', 
    'NOT': '1010'
}

REGISTERS = {
    'R0': '0000', 'R1': '0001', 'R2': '0010', 'R3': '0011',
    'R4': '0100', 'R5': '0101', 'R6': '0110', 'R7': '0111',
    'R8': '1000', 'R9': '1001', 'R10': '1010', 'R11': '1011',
    'R12': '1100', 'R13': '1101', 'R14': '1110', 'R15': '1111'
}

# First pass to identify labels and their corresponding memory addresses
def first_pass(assembly_code):
    label_table = {}
    address = 0

    for line in assembly_code:
        line = line.strip()
        if not line or line.startswith(';'):
            continue

        if ':' in line:
            label, instruction = line.split(':', 1)
            label = label.strip()
            label_table[label] = address
            line = instruction.strip()

        if line:
            address += 1

    return label_table

# Convert an instruction line into binary based on the opcode and format
def assemble_instruction(line, label_table):
    parts = line.split()
    if not parts:
        return None

    opcode = parts[0].upper()
    if opcode not in OPCODES:
        raise ValueError(f"Unknown opcode: {opcode}")

    binary_code = OPCODES[opcode]

    if opcode in ['ADD', 'SUB', 'DIV']:  
        rd = REGISTERS[parts[1].strip(',')]
        r1 = REGISTERS[parts[2].strip(',')]
        r2 = REGISTERS[parts[3].strip(',')]
        binary_code += rd + r1 + r2  

    elif opcode == 'LDR':
        rd = REGISTERS[parts[1].strip(',')]
        imm_value = format(int(parts[2]), '08b')
        binary_code += rd + imm_value  

    elif opcode == 'MOV':  
        rd = REGISTERS[parts[1].strip(',')]
        rs = REGISTERS[parts[2].strip(',')]
        dummy_value = '00000000'
        binary_code += rd + rs + dummy_value  

    elif opcode in ['AND', 'OR', 'XOR']:  
        rd = REGISTERS[parts[1].strip(',')]
        r1 = REGISTERS[parts[2].strip(',')]
        r2 = REGISTERS[parts[3].strip(',')]
        binary_code += rd + r1 + r2  

    elif opcode == 'SHL':
        rd = REGISTERS[parts[1].strip(',')]
        rs = REGISTERS[parts[2].strip(',')]
        mode = parts[3].strip(',')
        imm_value = format(int(parts[4]), '08b')
        binary_code += '00' + rd + rs + imm_value + '00' if mode == '00' else '11' + rd + rs + imm_value + '11'

    elif opcode == 'SHR':
        rd = REGISTERS[parts[1].strip(',')]
        rs = REGISTERS[parts[2].strip(',')]
        mode = parts[3].strip(',')
        imm_value = format(int(parts[4]), '08b')
        binary_code += '00' + rd + rs + imm_value + '00' if mode == '00' else '11' + rd + rs + imm_value + '11'

    elif opcode == 'NOT':
        rd = REGISTERS[parts[1].strip(',')]
        rs = REGISTERS[parts[2].strip(',')]
        mode = parts[3].strip(',')
        if mode not in ['0000', '1111']:
            raise ValueError(f"Invalid mode for NOT operation: {mode}")
        binary_code += rd + rs + mode  

    elif opcode == 'LDM':  
        rd = REGISTERS[parts[1].strip(',')]
        memaddr = format(int(parts[2]), '08b')
        binary_code += rd + memaddr  

    elif opcode == 'STM':  
        rd = REGISTERS[parts[1].strip(',')]
        memaddr = format(int(parts[2]), '08b')
        binary_code += rd + memaddr  

    else:
        raise ValueError(f"Unsupported operation: {opcode}")

    return binary_code

# Main assembler function to process assembly file
def assemble_file(input_filename, output_filename):
    with open(input_filename, 'r') as f:
        assembly_code = f.readlines()

    label_table = first_pass(assembly_code)
    machine_code = []

    for line in assembly_code:
        line = line.strip()
        if not line or line.startswith(';') or ':' in line:
            continue

        binary_instruction = assemble_instruction(line, label_table)
        if binary_instruction:
            machine_code.append(binary_instruction)

    with open(output_filename, 'w') as f:
        for binary in machine_code:
            f.write(binary + '\n')

# Command-line argument parsing
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Assemble an assembly file into machine code.")
    parser.add_argument("input_file", help="The input assembly file to assemble.")
    parser.add_argument("output_file", help="The output binary file to save the machine code.")
    args = parser.parse_args()

    # Run assembler with the provided input and output filenames
    assemble_file(args.input_file, args.output_file)
    print(f"Assembly complete. Machine code written to {args.output_file}")

