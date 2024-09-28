#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2024 <student name>
#
# Redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#------------------------------------------------------------------------------
# CCID: adhaliw4
# Lecture Section:Lecture A1
# Instructor: Mike Macgregor
# Lab Section: Lab D05
# Teaching Assistant:
#-----------------------------------------------------------------------------

.include "common.s"
.text

# -----------------------------------------------------------------------------
# stringSearch:
#
# Sum all the locations of QUERY in the SEARCH string.
#
# Args:
#   a0: Pointer to the query string
#   a1: Pointer to the search string
#
# Returns:
#   a0: Search count
#
# Register Usage:
# -----------------------------------------------------------------------------

stringSearch:
	addi    sp, sp, -16        # Allocate space for stack
	sw      ra, 12(sp)         # Save the return address
    	sw      s0, 8(sp)          # Save the sum of the indices
    	sw      s1, 4(sp)          # Store the current index of string
    	sw      s2, 0(sp)          # store the pointyer to the string
    	mv      s0, zero           # Initialize the sum of the indices 
    	mv      s1, zero           # Initialize the current index 
    	mv      s2, a1             # move pointer value into register
    	beq     a0, zero, end      # If query string is empty jump to the end
    	beq     s2, zero, end      # If search string is empty jump to the end

searchLoop:
    	lb      t0, 0(s2)          # Load the current character from the string
    	beq     t0, zero, end      # If null terminator then exit the loop
    	mv      t1, s2             # t1 holds the current position in the search string
    	mv      t2, a0             # t2 points to the start of the query string

comparePosition:
    	lb      t3, 0(t1)          # Load the current character from the search string
    	lb      t4, 0(t2)          # Load the current character from the query string
    	beq     t4, zero, sum      # If end of the query string is reached add the current index to the total
    	bne     t3, t4, nextChar   # If not then move to the next position
		addi    t1, t1, 1          # Move to the next character in the search string
    	addi    t2, t2, 1          # Move to the next character in the query string
    	j       comparePosition    # Repeat

sum:
    	add     s0, s0, s1         # Add the current index to the total

nextChar:
    	addi    s2, s2, 1          # Move to the next position in the search string
    	addi    s1, s1, 1          # add to the index counter
    	j       searchLoop        # Repeat 

end:
    	mv      a0, s0             # Move the sum into a0
    	lw      ra, 12(sp)         # Retrieve the return address
    	lw      s0, 8(sp)          # Fetch the sum of the indices
    	lw      s1, 4(sp)          # Restore the current index from the stack
    	lw      s2, 0(sp)          # Restore the pointer to the search string
    	addi    sp, sp, 16         # Clear the stack space
    	jalr    zero, 0(ra)        # Return

