CXX ?= g++
TARGET ?= Breeze5
CPPFLAGS ?= -Iinclude -DNDEBUG
CXXFLAGS ?= -O3 -std=c++17 -Wall -Wextra -Wpedantic -flto
LDFLAGS ?= -flto -pthread
AVX2 ?= 1

ifeq ($(AVX2),1)
ISA_CXXFLAGS := -mavx2
else
ISA_CXXFLAGS :=
endif

SRC := src/main.cpp src/chess.cpp src/eval.cpp src/nnue.cpp src/search.cpp src/uci.cpp
OBJ := $(SRC:.cpp=.o)
ENGINE_OBJS := $(filter-out src/main.o,$(OBJ))
HEADER := include/breeze.hpp
PERFT_TEST := tests/perft_test.cpp
UCI_TEST := tests/uci_smoke.sh
NNUE_TEST := tests/nnue_smoke.sh

.PHONY: all clean debug portable windows-static test uci-test nnue-test
all: $(TARGET)

$(TARGET): $(OBJ)
	$(CXX) $(OBJ) $(LDFLAGS) -o $@

%.o: %.cpp $(HEADER)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ISA_CXXFLAGS) -c $< -o $@

debug:
	$(MAKE) clean TARGET=$(TARGET)
	$(MAKE) TARGET=$(TARGET) AVX2=0 CPPFLAGS="-Iinclude" CXXFLAGS="-O0 -g3 -std=c++17 -Wall -Wextra -Wpedantic -fsanitize=address,undefined" LDFLAGS="-pthread -fsanitize=address,undefined" all

portable:
	$(MAKE) clean TARGET=$(TARGET)
	$(MAKE) TARGET=$(TARGET) AVX2=0 CPPFLAGS="-Iinclude -DNDEBUG" CXXFLAGS="-O3 -std=c++17 -Wall -Wextra -Wpedantic" LDFLAGS="-pthread" all

windows-static:
	$(MAKE) clean TARGET=$(TARGET)
	$(MAKE) TARGET=$(TARGET) AVX2=$(AVX2) CPPFLAGS="-Iinclude -DNDEBUG" CXXFLAGS="-O3 -std=c++17 -Wall -Wextra -Wpedantic" LDFLAGS="-static -static-libgcc -static-libstdc++ -pthread -Wl,-Bstatic -lwinpthread -Wl,-Bdynamic" all

test: all
	$(CXX) $(CPPFLAGS) -O2 -std=c++17 -Wall -Wextra -Wpedantic $(ISA_CXXFLAGS) $(PERFT_TEST) src/chess.cpp src/eval.cpp src/nnue.cpp src/search.cpp -pthread -o Breeze5PerftTests
	./Breeze5PerftTests
	bash ./$(UCI_TEST) ./$(TARGET)

uci-test: all
	bash ./$(UCI_TEST) ./$(TARGET)

nnue-test: all
	@test -n "$(NETWORK)" || (echo "Set NETWORK=/path/to/nn-68752b755c93.nnue" >&2; exit 2)
	bash ./$(NNUE_TEST) ./$(TARGET) "$(NETWORK)"

clean:
	rm -f $(OBJ) $(TARGET) Breeze5PerftTests perft_test debug_moves
