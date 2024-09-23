package bbc

import "core:fmt"

main :: proc() {
    init_all()

    move_list : Moves
    add_move(&move_list, encode_move(get_square(.d7), get_square(.e8), P, Q, 1, 0, 0, 0))
    add_move(&move_list, encode_move(get_square(.e1), get_square(.f2), p, R, 0, 1, 1, 0))
    add_move(&move_list, encode_move(get_square(.a1), get_square(.b3), k, N, 0, 1, 0, 1))
    print_move_list(&move_list)

}
