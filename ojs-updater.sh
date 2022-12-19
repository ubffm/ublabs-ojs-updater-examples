#!/bin/bash
PYTHON_CMD="/usr/local/ojs/updater_venv/bin/python"
UPDATE_PATH="/usr/local/ojs/updater_venv/bin/ojs_updater"
"$PYTHON_CMD" "$UPDATE_PATH" "$@"
