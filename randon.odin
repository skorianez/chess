package bbc

import "core:fmt"

rook_magic_numbers :[64]u64 ={
    0x8a80104000800020,
    0x140002000100040,
    0x2801880a0017001,
    0x100081001000420,
    0x200020010080420,
    0x3001c0002010008,
    0x8480008002000100,
    0x2080088004402900,
    0x800098204000,
    0x2024401000200040,
    0x100802000801000,
    0x120800800801000,
    0x208808088000400,
    0x2802200800400,
    0x2200800100020080,
    0x801000060821100,
    0x80044006422000,
    0x100808020004000,
    0x12108a0010204200,
    0x140848010000802,
    0x481828014002800,
    0x8094004002004100,
    0x4010040010010802,
    0x20008806104,
    0x100400080208000,
    0x2040002120081000,
    0x21200680100081,
    0x20100080080080,
    0x2000a00200410,
    0x20080800400,
    0x80088400100102,
    0x80004600042881,
    0x4040008040800020,
    0x440003000200801,
    0x4200011004500,
    0x188020010100100,
    0x14800401802800,
    0x2080040080800200,
    0x124080204001001,
    0x200046502000484,
    0x480400080088020,
    0x1000422010034000,
    0x30200100110040,
    0x100021010009,
    0x2002080100110004,
    0x202008004008002,
    0x20020004010100,
    0x2048440040820001,
    0x101002200408200,
    0x40802000401080,
    0x4008142004410100,
    0x2060820c0120200,
    0x1001004080100,
    0x20c020080040080,
    0x2935610830022400,
    0x44440041009200,
    0x280001040802101,
    0x2100190040002085,
    0x80c0084100102001,
    0x4024081001000421,
    0x20030a0244872,
    0x12001008414402,
    0x2006104900a0804,
    0x1004081002402, 
}

bishop_magic_numbers :[64]u64 ={
    0x40040844404084,
    0x2004208a004208,
    0x10190041080202,
    0x108060845042010,
    0x581104180800210,
    0x2112080446200010,
    0x1080820820060210,
    0x3c0808410220200,
    0x4050404440404,
    0x21001420088,
    0x24d0080801082102,
    0x1020a0a020400,
    0x40308200402,
    0x4011002100800,
    0x401484104104005,
    0x801010402020200,
    0x400210c3880100,
    0x404022024108200,
    0x810018200204102,
    0x4002801a02003,
    0x85040820080400,
    0x810102c808880400,
    0xe900410884800,
    0x8002020480840102,
    0x220200865090201,
    0x2010100a02021202,
    0x152048408022401,
    0x20080002081110,
    0x4001001021004000,
    0x800040400a011002,
    0xe4004081011002,
    0x1c004001012080,
    0x8004200962a00220,
    0x8422100208500202,
    0x2000402200300c08,
    0x8646020080080080,
    0x80020a0200100808,
    0x2010004880111000,
    0x623000a080011400,
    0x42008c0340209202,
    0x209188240001000,
    0x400408a884001800,
    0x110400a6080400,
    0x1840060a44020800,
    0x90080104000041,
    0x201011000808101,
    0x1a2208080504f080,
    0x8012020600211212,
    0x500861011240000,
    0x180806108200800,
    0x4000020e01040044,
    0x300000261044000a,
    0x802241102020002,
    0x20906061210001,
    0x5a84841004010310,
    0x4010801011c04,
    0xa010109502200,
    0x4a02012000,
    0x500201010098b028,
    0x8040002811040900,
    0x28000010020204,
    0x6000020202d0240,
    0x8918844842082200,
    0x4010011029020020,
}

random_state :u32 =  1804289383 // Gerado vai random()

get_random_u32_number :: proc() -> u32 {
    number := random_state

    number ~= (number << 13)
    number ~= (number >> 17)
    number ~= (number << 5)
    random_state = number

    return number
}

get_random_u64_number :: proc() -> u64 {
    n1 := u64(get_random_u32_number()) & 0xFFFF
    n2 := u64(get_random_u32_number()) & 0xFFFF
    n3 := u64(get_random_u32_number()) & 0xFFFF
    n4 := u64(get_random_u32_number()) & 0xFFFF
    return n1 | n2 << 16 | n3 << 32 | n4 << 48
}

generate_magic_number :: proc() -> u64 {
    return get_random_u64_number() & get_random_u64_number() & get_random_u64_number()
}

find_magic_number ::proc(square, relevant_bits, piece :i32 ) -> u64 {
    occupancies, attacks, used_attacks: [4096]u64

    attack_mask := piece == bishop ? mask_bishop_attacks(square) : mask_rook_attacks(square)

    occupancy_indicies := 1 << u32(relevant_bits)

    for index in 0..<occupancy_indicies {
        occupancies[index] = set_occupancy(i32(index), relevant_bits, attack_mask)
        attacks[index] = piece == bishop ? bishop_attacks_on_the_fly(square, occupancies[index]) : rook_attacks_on_the_fly(square, occupancies[index])
    }

    // test magick number
    for randon_count in 0..< 100_000_000 {
        magic_number := generate_magic_number()
        if count_bits((attack_mask * magic_number) & 0xFF00_0000_0000_0000 ) < 6 { 
            continue 
        }
        used_attacks = {}
        
        fail : bool 
        for index := 0; !fail  && index < occupancy_indicies ; index += 1 {

            magic_index := i32((occupancies[index] * magic_number) >> u32(64 - relevant_bits))
            if used_attacks[magic_index] == 0 {
                used_attacks[magic_index] = attacks[index]
            } else if used_attacks[magic_index] != attacks[index] {
                fail = true;
            }            
        }
        if !fail  {
            return magic_number
        }
    }
    fmt.printf("MAGIC NUMBER FAILS!\n")
    return  0
}

init_magic_number ::proc() {
    fmt.printf("ROOK \n")
    for square in 0..<64 {
        fmt.printf(" 0x%x,\n", find_magic_number(i32(square), rook_relevant_bits[square], rook))
    }
    fmt.printf("BISHOP \n")
    for square in 0..<64 {
        fmt.printf(" 0x%x,\n", find_magic_number(i32(square), bishop_relevant_bits[square], bishop))
    }
}