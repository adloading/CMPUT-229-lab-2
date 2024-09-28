#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2024 University of Alberta
# Copyright 2024 Nathan Ulmer
#
# This software is distributed to students in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the disclaimer below in the documentation
#    and/or other materials provided with the distribution.
#
# 2. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#-------------------------------
# Lab - String Search
#
# Author: Nathan Ulmer
# Date: July 2, 2024
#
# This file provides functions to read and parse input files for the
# stringSearch lab.
#-------------------------------
#

.data

# File data
_input_stream:  .space 512		# Space for the input file
_open_error:    .asciz "ERROR: Couldn't open specified file.\n"

# Input as strings
_n1_str:	.space 256
_n2_str:	.space 256
_newline:	.byte 0x0a

.text

_main:
	# Get the file descriptor
	lw		a0, 0(a1)
	li		a1, 0				# Read only file
	li		a7, 1024			# Ecall for file IO
	ecall
	# a0 < 0 if there is an error
	bltz	a0, _input_error
	# Read the file
	la		a1, _input_stream	# Buffer to write to
	li		a2, 1024			# Max character to write
	li		a7, 63				# Read characters syscall
	ecall
	# Get rid of DOS line terminators
	la		a0, _input_stream
	jal		_kill_cr
	# Break the two strings by the newline
	la		a0, _input_stream
	la		a1, _n1_str
	la		a2, _n2_str
	jal		_split_file
	# Call the user's function
	la		a0, _n1_str
	la		a1, _n2_str
	jal		stringSearch
	# Print the result (a0 <- result)
	addi	a7, zero, 1
	ecall
	# Exit with no errors
	li		a7, 10
	ecall

# -----------------------------------------------------------------------------
# kill_cr:
#
# Convert DOS-style line terminators to UNIX-style ones. The conversion is
# performed in place.
#
# Args:
#   a0: Pointer to a string
#
# Register Usage:
#	t0: Copy-to pointer
#	t1: Loader char
#	t6: 0x0d (for comparison)
# -----------------------------------------------------------------------------
_kill_cr:
	mv      t0, a0
	addi    t6, zero, 0x0d          # t6 <- '\r'
_kill_cr_loop:
	lbu     t1, 0(a0)               # Read the next character
	sb      t1, 0(t0)               # Copy the charcater
	beqz    t1, _kill_cr_exit       # Exit if 0x00
	addi    a0, a0, 1               # Move to the next character
	beq     t1, t6, _kill_cr_loop
	addi    t0, t0, 1               # Skip the '\r'
	j       _kill_cr_loop
_kill_cr_exit:
	ret

_split_file:
	la		t0, _newline
	lb		t0, 0(t0)
_sf_first:
	# Copy the first line into the _n1 buffer
	lb		t1, 0(a0)			# Move the character into the n1 buffer
	sb		t1, 0(a1)
	addi	a0, a0, 1			# Move to the next char
	addi	a1, a1, 1
	bne		t1, t0, _sf_first	# Continue if we haven't reached the newline
	# Exit
	sb		zero, -1(a1)		# Overwrite the newline with a null char
_sf_second:
	# Copy the second line into the _n2 buffer
	lb		t1, 0(a0)			# Move the character into the n1 buffer
	sb		t1, 0(a2)
	addi	a0, a0, 1			# Move to the next char
	addi	a2, a2, 1
	beq		t1, t0, _sf_skip	# Handle the trailing newline
	beq		t1, zero, _sf_skip	# Handle no trailing newline
	j		_sf_second
_sf_skip:
	# Return
	sb		zero, -1(a2)		# Overwrite the newline will a null char
	ret

_input_error:
	# Print the error message
	la		a0,	_open_error		# File error message
	li		a7, 4				# Print syscall
	ecall
	# Exit with an error code
	li		a0, 1
	li		a7, 93				# Exit syscall
	ecall

