# Breeze 5 SFNNv20 performance repair

## Changes made

- Reuses thread-local feature-index vectors instead of repeatedly allocating six vectors for each NNUE evaluation.
- Uses AVX2 sign-extension and 32-bit accumulation for the sparse feature-transformer rows.
- Uses AVX2 `maddubs`/`madd` dot products for the 1024→32, 64→32, and 128→1 dense paths.
- Retains scalar fallback code when the binary is compiled without AVX2.
- Repairs Makefile/CMake source-path selection for both root-level and `src/` + `include/` project layouts.
- Enables AVX2 in the MSYS2 UCRT64 build script for the target i5-11500H class CPU.

## Deliberate limitation

This is not a full incremental NNUE accumulator implementation. The K32H3, FullThreats, and PP_3Wide active feature lists are still regenerated per evaluation. Implementing a correct incremental stack requires carefully tracking piece-square, king-bucket refresh, threat, and pawn-pair feature deltas through every make/unmake and null-move path; this repair does not fake that work.

## Build and verify

In MSYS2 UCRT64, from this folder:

```bash
./build_ucrt64.sh
make TARGET=Breeze5.exe AVX2=1 nnue-test NETWORK="/c/Users/Polygon/Desktop/Breeze5_SFNNv20_CleanRoom/nn-68752b755c93.nnue"
objdump -p Breeze5.exe | grep 'DLL Name'
```

Run a matched benchmark against an AVX2=0 scalar build using the same network, FEN, hash, and node limit. Check that `eval` reports SFNNv20 and that evaluation scores agree exactly between scalar and AVX2 binaries on a FEN corpus. Then compare NPS. This installer does not claim a measured NPS result: it has no access to the user's 138 MB network file or Windows CPU.
