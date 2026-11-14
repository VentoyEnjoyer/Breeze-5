#include "breeze.hpp"
#include <iostream>
#include <string>
#include <vector>

struct Case {
    const char* name;
    const char* fen;
    std::vector<uint64_t> expected;
    int maxDepth;
};

int main() {
    const std::vector<Case> cases = {
        {"startpos", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", {1,20,400,8902,197281,4865609}, 5},
        {"kiwipete", "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1", {1,48,2039,97862,4085603}, 4},
        {"position3", "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1", {1,14,191,2812,43238}, 4},
        {"position4", "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1", {1,6,264,9467,422333}, 4},
        {"position5", "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8", {1,44,1486,62379}, 3},
        {"position6", "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10", {1,46,2079,89890}, 3}
    };

    for (const Case& c : cases) {
        breeze::Board board;
        std::string error;
        if (!board.setFEN(c.fen, &error)) {
            std::cerr << c.name << ": FEN error: " << error << '\n';
            return 2;
        }
        const uint64_t rootHash = board.hash();
        for (const breeze::Move& move : board.legalMoves()) {
            breeze::Undo undo;
            if (!board.makeMove(move, undo)) return 4;
            breeze::Board rebuilt;
            if (!rebuilt.setFEN(board.fen(), &error) || rebuilt.hash() != board.hash()) {
                std::cerr << c.name << ": incremental hash mismatch after "
                          << breeze::Board::moveToUci(move) << '\n';
                return 5;
            }
            board.unmakeMove(undo);
            if (board.hash() != rootHash) return 6;
        }
        for (int depth = 1; depth <= c.maxDepth; ++depth) {
            const uint64_t actual = breeze::perft(board, depth);
            const uint64_t expected = c.expected[depth];
            std::cout << c.name << " perft(" << depth << ")=" << actual << " expected=" << expected << '\n';
            if (actual != expected) return 3;
        }
    }
    return 0;
}
