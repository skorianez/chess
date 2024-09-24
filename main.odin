package bbc

import "core:fmt"
import "core:c/libc"

// FEN debug positions
empty_board :: "8/8/8/8/8/8/8/8 w - - "
start_position :: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 "
tricky_position :: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1 "
killer_position :: "rnbqkb1r/pp1p1pPp/8/2p1pP2/1P1P4/3P3P/P1P1P3/RNBQKBNR w KQkq e6 0 1"
cmk_position :: "r2q1rk1/ppp2ppp/2n1bn2/2b1p3/3pP3/3P1NPP/PPP1NPB1/R1BQ1RK1 b - - 0 9 "


main :: proc() {
    init_all()

    parse_fen("r3k2r/p6p/8/8/8/8/P6P/R3K2R w KQkq - 0 1 ")
    print_board()

    move_list : Moves
    generate_moves(&move_list)

    for move_count in 0..< move_list.count {
        move := move_list.moves[move_count]
        copy_board()
        make_move(move, ALL_MOVES) 
        //print_board()
        print_bitboard(occupancies[both])
        libc.getchar()

        take_back()
        //print_board()
        print_bitboard(occupancies[both])
        libc.getchar()
    }
}
