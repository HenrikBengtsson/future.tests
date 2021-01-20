include .make/Makefile
include Makefile.backend-tests

spelling:
	$(R_SCRIPT) -e "spelling::spell_check_package()"
