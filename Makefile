.DEFAULT_GOAL := help

VENV_PY := $(HOME)/klippy-env/bin/python
CALIBRATE_SHAPER := $(HOME)/klipper/scripts/calibrate_shaper.py

.PHONY: help check-python shaper-x shaper-y shaper-both shaper-latest

help:
	@printf "Available targets:\n"
	@printf "  make check-python   Verify python/venv and imports\n"
	@printf "  make shaper-x       Analyze latest /tmp/calibration_data_x_*.csv\n"
	@printf "  make shaper-y       Analyze latest /tmp/calibration_data_y_*.csv\n"
	@printf "  make shaper-both    Run shaper-x then shaper-y\n"
	@printf "  make shaper-latest  Alias for shaper-both\n"

check-python:
	@set -e; \
	command -v python3; \
	python3 -c 'import sys; print("system:", sys.executable)'; \
	"$(VENV_PY)" -c 'import sys, numpy, matplotlib; print("venv:", sys.executable); print("numpy:", numpy.__version__); print("matplotlib:", matplotlib.__version__)'

shaper-x:
	@set -e; \
	csv=$$(ls -t /tmp/calibration_data_x_*.csv 2>/dev/null | head -n1); \
	if [ -z "$$csv" ]; then \
		printf "No /tmp/calibration_data_x_*.csv found\n"; \
		exit 1; \
	fi; \
	ts=$${csv##*_}; \
	ts=$${ts%.csv}; \
	png="/tmp/shaper_calibrate_x_$${ts}.png"; \
	printf "Input : %s\n" "$$csv"; \
	printf "Output: %s\n" "$$png"; \
	"$(VENV_PY)" "$(CALIBRATE_SHAPER)" "$$csv" -o "$$png"

shaper-y:
	@set -e; \
	csv=$$(ls -t /tmp/calibration_data_y_*.csv 2>/dev/null | head -n1); \
	if [ -z "$$csv" ]; then \
		printf "No /tmp/calibration_data_y_*.csv found\n"; \
		exit 1; \
	fi; \
	ts=$${csv##*_}; \
	ts=$${ts%.csv}; \
	png="/tmp/shaper_calibrate_y_$${ts}.png"; \
	printf "Input : %s\n" "$$csv"; \
	printf "Output: %s\n" "$$png"; \
	"$(VENV_PY)" "$(CALIBRATE_SHAPER)" "$$csv" -o "$$png"

shaper-both:
	@$(MAKE) shaper-x
	@$(MAKE) shaper-y

shaper-latest: shaper-both
