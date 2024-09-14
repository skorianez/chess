package bbc

state :u32 =  1804289383 // Gerado vai random()

get_random_u32_number :: proc() -> u32 {
    number := state

    number ~= (number << 13)
    number ~= (number >> 17)
    number ~= (number << 5)
    state = number

    return number
}

get_random_u64_number :: proc() -> u64 {
    n1 := u64(get_random_u32_number() & 0xFFFF )
    n2 := u64(get_random_u32_number() & 0xFFFF )
    n3 := u64(get_random_u32_number() & 0xFFFF )
    n4 := u64(get_random_u32_number() & 0xFFFF )
    return n1 | n2 << 16 | n3 << 32 | n4 << 48
}

generate_magic_number :: proc() -> u64 {
    return get_random_u64_number() & get_random_u64_number() & get_random_u64_number()
}
