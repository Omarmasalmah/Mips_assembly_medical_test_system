#    ****************************************************************************
#    *      Title: Medical Test Management System in MIPS Assembly              *
#    *                                                                          *
#    *	       ---------> Authors <-------- 					*
#    *		    Omar Masalmah	     1200060   	                        *
#    *		    Mohammad abu shams 	     1200549	                        *
#    *                                                                          *
#    ****************************************************************************


############# 	Data segment ###############

.data
test_file: .space 256
menu: .asciiz "\n\nChoose an option:\n-------------------------------------\n1. Add a new medical test\n2. Search for a test by patient ID\n3. Search for unnormal patient tests\n4. Average test value\n5. Update an existing test result\n6. Delete a test\n7. Exit\n-------------------------------------\nEnter an Option: "
search_choices: .asciiz  "\n\nChoose an option:\n---------------------------------------------------\n1. Retrieve all patient tests\n2. Retrieve all up normal patient tests\n3. Retrieve all patient tests in a given specific period\n4. Go back to main menu\n---------------------------------------------------\nEnter an Option: "
invalid: .asciiz "\nInvalid input. Please try again.\n"
exit: .asciiz "\n---------------> Exiting program. <-------------\n"
enterFileName: .asciiz "Hello, Enter the name of file: "
enter_id: .asciiz "\nEnter Patient ID (7 digits): "
enter_name: .asciiz "\nEnter Test Name (HGB, BGT, LDL, BPT): "
enter_date: .asciiz "\nEnter Test Date (YYYY-MM): "
enter_result: .asciiz "\nEnter Test Result: "
enter_result_hgb: .asciiz "\nEnter The Result for Hgb Test: "
enter_result_bgt: .asciiz "\nEnter The Result for BGT Test: "
enter_result_ldl: .asciiz "\nEnter The Result for LDL Test: "
enter_result_bpt_s: .asciiz "\nEnter Systolic Blood Pressure Result for BPT Test: "
enter_result_bpt_d: .asciiz "\nEnter Diastolic Blood Pressure Result for BPT Test: "
enter_search_id: .asciiz "\nEnter Patient ID to search: "
enter_delete_line: .asciiz "\nEnter number of line for test to delete: "
enter_update_line: .asciiz "\nEnter number of line for test to update: "
enter_update_result: .asciiz "\nEnter The New Result: "
enter_update_result1: .asciiz "\nEnter The New Result for Systolic Blood Pressure: "
enter_update_result2: .asciiz "\nEnter The New Result for Diastolic Blood Pressure: "
enter_period: .asciiz "\nEnter Period (YYYY-MM): "
test_not_found: .asciiz "\nTest not found.\n"
file_error: .asciiz "\nFile Not Found.\n"
file_close_error: .asciiz "\nError closing file.\n"
test_added: .asciiz "\nTest added successfully.\n"
test_deleted: .asciiz "\nTest deleted successfully.\n"
test_updated: .asciiz "\nTest updated successfully.\n"
abnormal_header: .asciiz "\nAbnormal Tests:\n"
valid_format: .asciiz "Date format is valid.\n"

enter_period1: .asciiz "\nEnter Min Period (YYYY-MM): "
enter_period2: .asciiz "\nEnter Max Period (YYYY-MM): "
invalid_date_msg: .asciiz "\nInvalid date format. Please enter the date in the format YYYY-MM.\n"

no_tests_found: .asciiz "\nNo tests found.\n"

HBG_string: .asciiz "Hgb"
BGT_string: .asciiz "BGT"
LDL_string: .asciiz "LDL"
BPT_string: .asciiz "BPT"
HBG_average: .asciiz "\nThe Average of Hgb: "
BGT_average: .asciiz "\nThe Average of BGT: "
LDL_average: .asciiz "\nThe Average of LDL: "
BPT_average: .asciiz "\nThe Average of BPT: "

buffer: .space 100   # buffer to store file input
name_buffer: .space 100
id_buffer: .space 20
date_buffer: .space 100
.align 2
float_buffer: .space 100
float_temp: .space 100
float_temp1: .space 100
float_temp2: .space 100
float1_buffer: .space 100
id_temp: .space 20
name_temp: .space 20

min_date: .space 100
max_date: .space 100

zeroFloat: .float 0.0
point1: .float 0.1
ten: .float 10.0

test_names:
    .asciiz "HGB"   # Valid test names
    .asciiz "Hgb"
    .asciiz "BGT"
    .asciiz "LDL"
    .asciiz "BPT"

# Define medical test constants
HGB_MIN: .float 13.8
HGB_MAX: .float 17.2

BGT_MIN: .float 70.0
BGT_MAX: .float 99.0

LDL_MIN: .float 0.0
LDL_MAX: .float 100.0

BPT_SYS_MAX: .float 120.0
BPT_DIA_MAX: .float 80.0

records: .space 32000 # Assuming 1000 records, each taking 32 bytes (4 + 20 + 7 + 1 for alignment)
search_results: .space 32000 # Assuming 1000 records, each taking 32 bytes (4 + 20 + 7 + 1 for alignment)
temp: .space 32000
no_of_records: .word 0 # number of test records in the file
no_of_chars: .word 0 # number of characters in the file
no_of_edit: .word 0


############# 	Code segment ###############
.text
.globl main
main: # main program entry
	start:
	# Check if file exists
	#ask the user to enter the file name
	la $a0, enterFileName
	li $v0, 4		#print string
	syscall
	# Read filename from user input (assuming you want to read it)
   	li $v0, 8        # syscall 8 = read string
    la $a0, test_file  # Address where the filename will be stored
    li $a1, 20     # Maximum number of characters to read
    syscall
    	
    jal replace_newline_with_null # replace the new line with null charachter
    	
    li $v0, 13            # syscall 15 = file status.  The status system call is used to obtain information about a file, such as its size, permissions, and other attributes.
  	la $a0, test_file     # file name
  	li $a1, 0 # flags are 0: reading, 1: writing
	li $a2, 0 # mode is ignored
  	syscall
  	move $s0, $v0


	# check if the file is exist
	andi $t1, $v0, 0x80000000
	# branch/skip if there is no error
	beqz $t1, file_exists # Branch if file exists
  	
  	# File does not exist
  	la $a0, file_error
   	li $v0, 4
  	syscall
  	j start


file_exists:
    #read the file
	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1, records 	# The buffer that holds the string of the WHOLE file
	li $a2, 32000		# hardcoded buffer length
	syscall
	sb $v0, no_of_chars	# number of chars in the file

    # count the number of records in the file
    la $t0, records
    li $t1, 0           # counter for the number of characters
    lw $t2, no_of_chars # number of characters in the file
    li $t3, 0           # counter for the number of records
    
      

count_records:
    beq $t1, $t2, end_count_records
    lb $t4, ($t0)
    bne $t4, '\n', skip_increment
    addi $t3, $t3, 1    # increment record counter
skip_increment:
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    j count_records

end_count_records:
	addi $t3, $t3, 1
    sb $t3, no_of_records  # store the number of records

    # print the number of records
    li $v0, 1
    lb $a0, no_of_records
    syscall

    # Close file
    li $v0, 16         # syscall 16 = close
    move $a0, $s0      # file descriptor
    syscall

    j display_menu


# Function to display menu
display_menu:
    li $v0, 4
    la $a0, menu
    syscall
    
    # Get user choice
    li $v0, 5
    syscall
    move $t0, $v0
    move $t5, $v0

    # Branch based on user choice
    beq $t0, 1, add_test
    beq $t0, 2, search_by_id
    beq $t0, 3, search_unnormal
    beq $t0, 4, average_test
    beq $t0, 5, update_test
    beq $t0, 6, delete_test
    beq $t0, 7, exit_program
    j invalid_input
    
exit_program:
    
    li $v0, 4
    la $a0, exit
    syscall  
    # Exit program
    li $v0, 10
    syscall
    
add_test:
   # Add a new medical test
    # Get user input for new test
    li $v0, 4
    la $a0, enter_id
    syscall   
    
    # Read id from user input
    la $a0, id_buffer  # Load address of id into $a0
    li $a1, 20  # Maximum number of characters to read
    li $v0, 8  # syscall 8 = read string
    syscall
    
    jal replace_newline_with_null # replace the new line with null charachter

    jal validate_id   # validate Patient ID
    beqz $v0, invalid_input # Invalid input

    li $v0, 4
    la $a0, enter_name
    syscall

   # Read name from user input
    la $a0, name_buffer  
    li $a1, 100  
    li $v0, 8  
    syscall
    
    jal replace_newline_with_null # replace the new line with null charachter
    jal validate_name   # validate test name
    beqz $v0, invalid_input # Invalid input

    li $v0, 4
    la $a0, enter_date
    syscall
    
    # Read date from user input
    la $a0, date_buffer  
    li $a1, 100  
    li $v0, 8  
    syscall
    
    jal replace_newline_with_null # replace the new line with null charachter

    jal validate_date_format   # validate test date
    beqz $v0, invalid_input # Invalid input

    jal validate_test_result
    beqz $v0, invalid_input # Invalid input

   # Print a newline character
    li $v0, 11   # System call code for print_char
    li $a0, 10   # ASCII value for newline
    syscall      

    # print whats in the file
    la $a0, records
    li $v0, 4		
    syscall

    
    # Write new test to file
    li $v0, 13            
    la $a0, test_file    
    li $a1, 1 # flags are 0: reading, 1: writing
    li $a2, 0 
    syscall
    move $s0, $v0
   
    li $v0, 15         # syscall 15 = write
    move $a0, $s0     
    la $a1, records

    la $a2,32000	    
    syscall

    # Close file
    li $v0, 16         # syscall 16 = close
    move $a0, $s0      # file descriptor
    syscall

    # add 1 to the number of records
    lw $t0, no_of_records
    addi $t0, $t0, 1
    sb $t0, no_of_records
    # Print success message
    li $v0, 4
    la $a0, test_added
    syscall

    j display_menu


search_by_id:
    # Search for a test by Patient ID
    # ask the user to enter the id
    li $v0, 4
    la $a0, enter_search_id
    syscall

    # Read id from user input
    la $a0, id_buffer 
    li $a1, 20  
    li $v0, 8  
    syscall

    jal replace_newline_with_null # replace the new line with null charachter

    # loop through the records to find the record with the same id
    li $s0, 0                      # Counter for the number of records
    la $s1, records
    la $s2, 0                      # the number of results found
    lb $s3, no_of_records
    la $s4, search_results         # pointer to the buffer to store the search results
    beq $s0, $s3, end_search_loop  # End of records

search_loop:
    la $a1, ($s1)       # Load address of the record
    la $a2, id_temp     # Load address of id_temp
    jal copy_string     # Copy the id from the record to id_temp

    # Check if the id matches (id_temp and id_buffer)
    la $a0, id_temp
    la $a0 , id_temp
    la $a1, id_buffer
    jal strings_isEqual # Check if the id matches
    bne $v0, 1, skip_save_record  # Branch if the id does not match
    
    # copy the record to the buffer
    la $a1, ($s1)       # Load address of the record to be copied
    la $a2, ($s4)       # Load address of the buffer
    jal copy_record     # Copy the record to the buffer
    la $s4, ($a2)       # Load address of the next record in the buffer
    addi $s2, $s2, 1  # Increment the number of results found

skip_save_record:
    addi $s0, $s0, 1  # Increment counter
    beq $s0, $s3, end_search_loop  # End of records
    la $a1, ($s1)  # Load address of the record
    jal point_next_record  # Move to the next record
    la $s1, ($a1)  # Load address of the next record
    b search_loop

end_search_loop:

    # check if the number of results found is 0
    bne $s2, 0, display_search_options  # Branch if results are found
 
    li $v0, 4
    la $a0, no_tests_found
    syscall

    j display_menu

display_search_options:
    # Display search options
    li $v0, 4
    la $a0, search_choices
    syscall

    # Get user choice
    li $v0, 5
    syscall
    move $t0, $v0

    # Branch based on user choice
    beq $t0, 1, print_all_search_results
    beq $t0, 2, print_abnormal_search_results
    beq $t0, 3, print_search_results_in_period
    beq $t0, 4, display_menu

    # print invalid input
    la $a0, invalid
    li $v0, 4
    syscall

    j display_search_options


print_all_search_results:

    # Print the search results
    la $a0, search_results  # Load address of the buffer
    li $v0, 4
    syscall

    j display_menu

print_abnormal_search_results:
    # loop through the records to check each test if it is normal or not and print the abnormal tests
    move $s0, $s2                   # number of all tests found for one patient
    la $s1, search_results 
    li $s2, 0                       # counter for the current record
    li $s3, 0                       # number of results found
    beq $s2, $s0, end_abnormal_search  

check_normal:
    la $a1, ($s1)       # Load address of the record
    # make the pointer a1 point to the testtype field
    jal point_next_field
    # copy the test type to the name_buffer buffer
    la $a2, name_buffer
    jal copy_string 

    # make the pointer a1 point to the result field
    la $a1, ($s1)
    jal point_next_field
    jal point_next_field
    jal point_next_field

    # copy the result to the float buffer
    la $a2, float_buffer
    jal copy_string

    # check the name of the test and compare it with the normal range
    la $a0, name_buffer    
    jal check_test_type
    beq $v0, 1, check_Hgb_test
    beq $v0, 2, check_BGT_test
    beq $v0, 3, check_LDL_test
    beq $v0, 4, check_BPT_test


check_Hgb_test:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float
    mov.s $f12, $f0

    # check if the result is normal
    jal check_Hgb
    beq $v0, 1, print_abnormal_test
    j skip_print_abnormal_test


check_BGT_test:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float
    mov.s $f12, $f0

    # check if the result is normal
    jal check_BGT

    beq $v0, 1, print_abnormal_test
    j skip_print_abnormal_test

check_LDL_test:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float
    mov.s $f12, $f0

    # check if the result is normal
    jal check_LDL

    beq $v0, 1, print_abnormal_test
    j skip_print_abnormal_test

check_BPT_test:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float
    mov.s $f7, $f0

    la $a1, ($s1)
    jal point_next_field
    jal point_next_field
    jal point_next_field
    jal point_next_field
    
    # copy the result to the float buffer
    la $a2, float_buffer
    jal copy_string

    la $s7, float_buffer
    jal string_to_float
    mov.s $f8, $f0

    jal check_BPT

    # check if the result is normal
    beq $v0, 1, print_abnormal_test
    j skip_print_abnormal_test

print_abnormal_test:
    # print the record with the abnormal test
    la $a1, ($s1)       # Load address of the record
    la $a2, buffer  # Load address of the buffer
    jal copy_record    
    addi $s3, $s3, 1  
    # Print the record
    la $a0, buffer  # Load address of the buffer
    li $v0, 4
    syscall

skip_print_abnormal_test:
    addi $s2, $s2, 1  
    beq $s2, $s0, end_abnormal_search  # End of records
    la $a1, ($s1)  # Load address of the record
    jal point_next_record  
    la $s1, ($a1)  
    b check_normal

end_abnormal_search:
    # check if the number of results found is 0 and print no tests found
    bnez $s3, display_menu  

    # Message for when no tests are found
    li $v0, 4
    la $a0, no_tests_found
    syscall

    j display_menu


print_search_results_in_period:
    # Print search results in a specific period
    # ask the user to enter min period
    li $v0, 4
    la $a0, enter_period1
    syscall

    # Read period from user input
    la $a0, min_date  # Load address of date into $a0
    li $a1, 100  
    li $v0, 8  
    syscall

    jal replace_newline_with_null # replace the new line with null charachter

    # copy the min_date to the date buffer
    la $a1, min_date
    la $a2, date_buffer
    jal copy_string

    jal validate_date_format   # validate test date
    bnez $v0,  enter_max_period# Invalid input

    # print invalid date
    la $a0, invalid_date_msg
    li $v0, 4
    syscall

    j print_search_results_in_period

enter_max_period:
    # ask the user to enter max period
    li $v0, 4
    la $a0, enter_period2
    syscall

    # Read period from user input
    la $a0, max_date  # Load address of date into $a0
    li $a1, 100  
    li $v0, 8  # syscall 8 = read string
    syscall

    jal replace_newline_with_null # replace the new line with null charachter

    # copy the max_date to the date buffer
    la $a1, max_date
    la $a2, date_buffer
    jal copy_string

    jal validate_date_format   # validate test date
    bnez $v0, start_period_search# Invalid input

    # print invalid date
    la $a0, invalid_date_msg
    li $v0, 4
    syscall

    j enter_max_period

start_period_search:

    # convert the form of yyyy-mm to yyyymm for min_date
    la $a0, min_date
    jal convert_date

    # convert min_date to integer
    la $a0, min_date
    jal atoi

    move $s5, $v0

    # convert the form of yyyy-mm to yyyymm for max_date
    la $a0, max_date
    jal convert_date

    # convert max_date to integer
    la $a0, max_date
    jal atoi

    move $s6, $v0

    # loop through search results to find the records in the specific period
    move $s0, $s2                   # number of all tests found for one patient
    la $s1, search_results
    la $s2, 0                       # counter for the current record
    li $s3, 0                       # number of results found
    beq $s2, $s0, end_period_search  

check_period:
    la $a1, ($s1)       # Load address of the record
    # make the pointer a1 point to the date field
    jal point_next_field
    jal point_next_field
    # copy the date to the date buffer
    la $a2, date_buffer
    jal copy_string

    # convert the form of yyyy-mm to yyyymm
    la $a0, date_buffer
    jal convert_date

    # convert string to integer
    la $a0, date_buffer
    jal atoi

    move $s7, $v0

    # check if the date is in the specific period
    blt $s7, $s5, skip_print_period_test
    bgt $s7, $s6, skip_print_period_test

    # copy the record to the buffer
    la $a1, ($s1)       # Load address of the record to be copied
    la $a2, buffer       
    jal copy_record    

    # Print the record
    la $a0, buffer  # Load address of the buffer
    li $v0, 4
    syscall

    addi $s3, $s3, 1  # Increment the number of results found


skip_print_period_test:
    addi $s2, $s2, 1  # Increment the current record
    beq $s2, $s0, end_period_search  # End of records
    la $a1, ($s1)  # Load address of the record
    jal point_next_record  
    la $s1, ($a1)  # Load address of the next record

    b check_period

end_period_search:
    # check if the number of results found is 0 and print no tests found
    bnez $s2, display_menu  # Branch if results are found

    # Message for when no tests are found
    li $v0, 4
    la $a0, no_tests_found
    syscall

    j display_menu


search_unnormal:
    # Search for unnormal based on input medical test
    # ask the user to enter the test type
    li $v0, 4
    la $a0, enter_name
    syscall

    # Read test type from user input
    la $a0, name_buffer  
    li $a1, 100  
    li $v0, 8  
    syscall

    jal replace_newline_with_null # replace the new line with null charachter

    # loop through the records to check each test if it is normal or not and print the abnormal tests
    lw $s0, no_of_records           # number of all records
    la $s1, records
    li $s2, 0                       # counter for the current record
    li $s3, 0                       
    beq $s2, $s0, end_unnormal_search  


check_unnormal:
    la $a1, ($s1)       # Load address of the record
    # make the pointer a1 point to the testtype field
    jal point_next_field
    # copy the test type to the name_buffer buffer
    la $a2, name_temp
    jal copy_string

    # make the pointer a1 point to the result field
    la $a1, ($s1)
    jal point_next_field
    jal point_next_field
    jal point_next_field

    # copy the result to the float buffer
    la $a2, float_buffer
    jal copy_string

    # check the name_buffer of the test and compare it with the input test
    la $a0, name_temp
    la $a1, name_buffer
    jal strings_isEqual # Check if the test matches
    beqz $v0, skip_print_unnormal_test  # Branch if the test does not match

    # else check if the test is normal or not
    # check the name_buffer of the test and compare it with the normal range
    la $a0, name_buffer    
    jal check_test_type
    beq $v0, 1, check_Hgb_test_unnormal
    beq $v0, 2, check_BGT_test_unnormal
    beq $v0, 3, check_LDL_test_unnormal
    beq $v0, 4, check_BPT_test_unnormal

check_Hgb_test_unnormal:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float
    mov.s $f12, $f0

    # check if the result is normal
    jal check_Hgb

    beq $v0, 1, print_unnormal_test
    j skip_print_unnormal_test


check_BGT_test_unnormal:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float
    mov.s $f12, $f0

    # check if the result is normal
    jal check_BGT

    beq $v0, 1, print_unnormal_test
    j skip_print_unnormal_test

check_LDL_test_unnormal:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float
    mov.s $f12, $f0

    # check if the result is normal
    jal check_LDL

    beq $v0, 1, print_unnormal_test
    j skip_print_unnormal_test

check_BPT_test_unnormal:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float
    mov.s $f7, $f0

    la $a1, ($s1)
    jal point_next_field
    jal point_next_field
    jal point_next_field
    jal point_next_field

    # copy the result to the float buffer
    la $a2, float_buffer
    jal copy_string

    la $s7, float_buffer
    jal string_to_float
    mov.s $f8, $f0

    jal check_BPT

    # check if the result is normal
    beq $v0, 1, print_unnormal_test
    j skip_print_unnormal_test

print_unnormal_test:
    # print the record with the abnormal test
    la $a1, ($s1)       # Load address of the record
    la $a2, buffer  # Load address of the buffer
    jal copy_record     

    addi $s3, $s3, 1  # Increment the number of results found

    # Print the record
    la $a0, buffer  # Load address of the buffer
    li $v0, 4
    syscall

skip_print_unnormal_test:
    
    addi $s2, $s2, 1  # Increment the current record
    beq $s2, $s0, end_unnormal_search  # End of records

    la $a1, ($s1)  # Load address of the record
    jal point_next_record  # Move to the next record
    la $s1, ($a1)  # Load address of the next record

    b check_unnormal


end_unnormal_search:
    # check if the number of results found is 0 and print no tests found
    bnez $s3, display_menu  # Branch if results are found

    # Message for when no tests are found
    li $v0, 4
    la $a0, no_tests_found
    syscall

    j display_menu

    
average_test:
    # Calculate the average of each test type
    # loop through the records to calculate the average of each test type
    lw $s0, no_of_records           # number of all records
    la $s1, records
    li $s2, 0                       # counter for the current record

    # initialize the sum of each test type
    l.s $f3, zeroFloat   # Hgb
    l.s $f4, zeroFloat   # BGT
    l.s $f5, zeroFloat   # LDL
    l.s $f6, zeroFloat   # BPT systolic
    l.s $f7, zeroFloat   # BPT diastolic

    # counter for each test type
    li $s3, 0
    li $s4, 0
    li $s5, 0
    li $s6, 0

    beq $s2, $s0, end_average_search  # End of records

calculate_average:
    la $a1, ($s1)       # Load address of the record
    # make the pointer a1 point to the testtype field
    jal point_next_field
    # copy the test type to the name buffer
    la $a2, name_buffer
    jal copy_string

    # make the pointer a1 point to the result field
    la $a1, ($s1)
    jal point_next_field
    jal point_next_field
    jal point_next_field

    # copy the result to the float buffer
    la $a2, float_buffer
    jal copy_string

    # check the name of the test and compare it with the normal range
    la $a0, name_buffer
    jal check_test_type
    beq $v0, 1, calculate_Hgb_average
    beq $v0, 2, calculate_BGT_average
    beq $v0, 3, calculate_LDL_average
    beq $v0, 4, calculate_BPT_average

calculate_Hgb_average:

    # print hgb
    la $a0, name_temp
    li $v0, 4
    syscall

    # convert the result to float
    la $s7, float_buffer
    jal string_to_float

    # add the result to the sum
    add.s $f3, $f3, $f0
    addi $s3, $s3, 1  # increment the counter

    j skip_calculate_average


calculate_BGT_average:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float

    # add the result to the sum
    add.s $f4, $f4, $f0
    addi $s4, $s4, 1  # increment the counter

    j skip_calculate_average

calculate_LDL_average:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float

    # add the result to the sum
    add.s $f5, $f5, $f0
    addi $s5, $s5, 1  # increment the counter

    j skip_calculate_average

calculate_BPT_average:
    # convert the result to float
    la $s7, float_buffer
    jal string_to_float

    # add the result to the sum
    add.s $f6, $f6, $f0
    addi $s6, $s6, 1  # increment the counter

    # diagnostic
    la $a1, ($s1)
    jal point_next_field
    jal point_next_field
    jal point_next_field
    jal point_next_field

    # copy the result to the float buffer
    la $a2, float_buffer
    jal copy_string
    la $s7, float_buffer
    jal string_to_float
    add.s $f7, $f7, $f0

    j skip_calculate_average


skip_calculate_average:

    addi $s2, $s2, 1  # Increment the current record
    beq $s2, $s0, end_average_search  
    la $a1, ($s1)  # Load address of the record
    jal point_next_record  # Move to the next record
    la $s1, ($a1)  # Load address of the next record

    b calculate_average

end_average_search:

    # Print the average message
    li $v0, 4
    la $a0, HBG_average
    syscall

    # check if the counter not zero and skip printing the average if it is zero
    beqz $s3, print_Hgb_average_zero

    mtc1 $s3, $f9
    cvt.s.w $f9, $f9
    
    # calculate the average and put it in f12 to print it
    div.s $f12, $f3, $f9

    # Print the average
    li $v0, 2
    syscall

    j print_BGT_avg

print_Hgb_average_zero:
    #print zero
    li $v0, 2
    l.s $f12, zeroFloat
    syscall

print_BGT_avg:
    # Print the average message
    li $v0, 4
    la $a0, BGT_average
    syscall

    # check if the counter not zero and skip printing the average if it is zero
    beqz $s4, print_BGT_average_zero

    mtc1 $s4, $f9
    cvt.s.w $f9, $f9
    # calculate the average and put it in f12 to print it
    div.s $f12, $f4, $f9

    # Print the average
    li $v0, 2
    syscall

    j print_LDL_avg

print_BGT_average_zero:
    #print zero
    li $v0, 2
    l.s $f12, zeroFloat
    syscall

print_LDL_avg:
    # Print the average message
    li $v0, 4
    la $a0, LDL_average
    syscall

    beqz $s5, print_LDL_average_zero

    mtc1 $s5, $f9
    cvt.s.w $f9, $f9
    # calculate the average and put it in f12 to print it
    div.s $f12, $f5, $f9

    # Print the average
    li $v0, 2
    syscall

    j print_BPT_avg

print_LDL_average_zero:
    #print zero 
    li $v0, 2
    l.s $f12, zeroFloat
    syscall

print_BPT_avg:
    # Print the average message
    li $v0, 4
    la $a0, BPT_average
    syscall

    beqz $s6, print_BPT_average_zero
    
    mtc1 $s6, $f9
    cvt.s.w $f9, $f9
    # calculate the average and put it in f12 to print it
    div.s $f12, $f6, $f9

    # Print the average
    li $v0, 2
    syscall

    #print "/"
    li $v0, 11
    li $a0, '/'
    syscall
    
    mtc1 $s6, $f9
    cvt.s.w $f9, $f9

    # calculate the average and put it in f12 to print it
    div.s $f12, $f7, $f9

    # Print the average
    li $v0, 2
    syscall

    j display_menu

print_BPT_average_zero:
    #print zero
    li $v0, 2
    l.s $f12, zeroFloat
    syscall

    #print "/"
    li $v0, 11
    li $a0, '/'
    syscall

    #print zero
    li $v0, 2
    l.s $f12, zeroFloat
    syscall

    j display_menu

    
invalid_input:
    # Invalid input handler
    li $v0, 4
    la $a0, invalid
    syscall
    j display_menu  

not_found:
    # Message for when no tests are found
    li $v0, 4
    la $a0, test_not_found
    syscall
    j display_menu
    

###############################################################################################################

validate_test_result:
    move $s5, $ra
    # Load address of the Test Name buffer
    la $t1, name_buffer
    lb $t2, ($t1)           # Load first character of Test Name
    lb $t3, 1($t1)          # Load second character of Test Name
    lb $t4, 2($t1)          # Load third character of Test Name

    # Check if the Test Name is "Hgb"
    li $t5, 'H'
    li $t6, 'G'
    li $t7, 'B'
    li $t8, 'g'
    li $t9, 'b'
    beq $t2, $t5, hgb
    j not_hgb

check_h:
    beq $t3, $t6, check_g_Hgb
    beq $t3, $t8, check_g_Hgb
    j not_hgb

check_g_Hgb:
    beq $t4, $t7, hgb
    beq $t4, $t9, hgb


not_hgb:
    # Check if the Test Name is "BGT"
    li $t5, 'B'
    li $t6, 'G'
    li $t7, 'T'
    beq $t2, $t5, check_b_BGT
    j not_bgt

check_b_BGT:
    beq $t3, $t6, check_g
    j not_bgt

check_g:
    beq $t4, $t7, BGT

not_bgt:
    # Check if the Test Name is "LDL"
    li $t5, 'L'
    li $t6, 'D'
    li $t7, 'L'
    beq $t2, $t5, ldl
    j not_ldl

check_l:
    beq $t3, $t6, check_d
    j not_ldl

check_d:
    beq $t4, $t7, ldl

not_ldl:
    # Check if the Test Name is "BPT"
    li $t5, 'B'
    li $t6, 'P'
    li $t7, 'T'
    beq $t2, $t5, check_b
    j not_bpt

check_b:
    beq $t3, $t6, check_t
    j not_bpt

check_t:
    beq $t4, $t7, bpt

not_bpt:
    # If not any of the known tests, treat as an unknown test( will not reach to here because we validate the name before)
    unknown_test:
        li $v0, 0    # Invalid test name, set result to 0
        jr $ra

hgb:
    
    l.s $f4, zeroFloat

    li $v0, 4
    la $a0, enter_result_hgb
    syscall
    
    # Read result from user input
    la $a0, float_buffer  # Load address of result into $a0
    li $a1, 9  
    li $v0, 8  
    syscall

    jal replace_newline_with_null # replace the new line with null charachter
 
    jal validate_float1
    beqz $v0, invalid_input # Invalid input
    la $s7, float_buffer
    jal string_to_float

    jal add_to_buffer
    
  move $ra, $s5  # Restore return address of main
    jr $ra


BGT:
    l.s $f4, zeroFloat

    li $v0, 4
    la $a0, enter_result_bgt
    syscall
    
    # Read result from user input
    la $a0, float_buffer  # Load address of result into $a0
    li $a1, 9  # Maximum number of characters to read
    li $v0, 8  # syscall 8 = read string
    syscall

    jal replace_newline_with_null # replace the new line with null charachter

    jal validate_float1
    beqz $v0, invalid_input # Invalid input

    la $s7, float_buffer
    jal string_to_float
     
    jal add_to_buffer

    # Compare the result with the normal range for BGT
    l.s $f2, BGT_MIN
    l.s $f3, BGT_MAX
    move $ra, $s5  # Restore return address of main
    jr $ra

ldl:
    l.s $f4, zeroFloat

    li $v0, 4
    la $a0, enter_result_ldl
    syscall
    
    # Read result from user input
    la $a0, float_buffer  # Load address of result into $a0
    li $a1, 9  
    li $v0, 8 
    syscall

    jal replace_newline_with_null # replace the new line with null charachter

    jal validate_float1
    beqz $v0, invalid_input # Invalid input
  
    la $s7, float_buffer
    jal string_to_float
     
    jal add_to_buffer

    # Compare the result with the normal range for LDL
    l.s $f2, LDL_MIN
    l.s $f3, LDL_MAX
    move $ra, $s5  # Restore return address of main
    jr $ra

bpt:

    l.s $f4, zeroFloat
  
    li $v0, 4
    la $a0, enter_result_bpt_s
    syscall
    
    # Read result from user input
    la $a0, float_buffer  # Load address of result into $a0
    li $a1, 9  
    li $v0, 8  
    syscall

    jal replace_newline_with_null # replace the new line with null charachter
 
    jal validate_float1
    beqz $v0, invalid_input # Invalid input
    la $s7, float_buffer
 
    jal string_to_float


    li $v0, 4
    la $a0, enter_result_bpt_d
    syscall
    
    # Read result from user input
    la $a0, float1_buffer  
    li $a1, 9  
    li $v0, 8  
    syscall

    jal replace_newline_with_null # replace the new line with null charachter
 
    jal validate_float1
    beqz $v0, invalid_input # Invalid input
  
    la $s7, float1_buffer
    jal string_to_float
  
    jal add_to_buffer2

    move $ra, $s5  # Restore return address of main
    jr $ra
  
    
validate_id:
    # Load the address of the id buffer into $a0
    la $a0, id_buffer

    # Check the length of the string
    li $t0, 0      # Counter for the number of characters
    la $t1, id_buffer  # Load address of id_buffer
    
validate_length_id:
    lb $t2, ($t1)  # Load byte from buffer
    beqz $t2, validate_id_end  # End of string if byte is 0 (null terminator)
    addi $t0, $t0, 1   # Increment counter
    addi $t1, $t1, 1  
    j validate_length_id 
   
validate_id_end:
    # Length should be 7
    li $t3, 7
    bne $t0, $t3, invalid_id  # Branch if length is not 7
    li $t6, 48           # ASCII value for '0'
    li $t7, 57           # ASCII value for '9'
    
    la $t1, id_buffer

    lb $t4, 0($t1)        # Load first degit
    blt $t4, $t6, invalid_id  # Branch if first character is not a digit
    bgt $t4, $t7, invalid_id  # Branch if first character is not a digit

    lb $t5, 1($t1)        # Load 2 degit
    blt $t5, $t6, invalid_id  
    bgt $t5, $t7, invalid_id  
    
    lb $t8, 2($t1)        # Load 3 degit
    blt $t8, $t6, invalid_id  
    bgt $t8, $t7, invalid_id  
    
    lb $t2, 3($t1)        # Load 4 degit
    blt $t2, $t6, invalid_id  
    bgt $t2, $t7, invalid_id 
    
    lb $t4, 4($t1)        # Load 5 degit
    blt $t4, $t6, invalid_id  
    bgt $t4, $t7, invalid_id  
    
    lb $t5, 5($t1)        # Load 6 degit 
    blt $t5, $t6, invalid_id  
    bgt $t5, $t7, invalid_id  
    
    lb $t8, 5($t1)        # Load 7 degit
    blt $t8, $t6, invalid_id  
    bgt $t8, $t7, invalid_id  
      
valid_id:
    li $v0, 1     
    jr $ra
     
invalid_id:
    # Invalid 
    li $v0, 0         
    jr $ra
 

# Function to validate the name
validate_name:
    # Load the address of the name buffer into $a0
    la $a0, name_buffer
    # Check the length of the string
    li $t0, 0      # Counter for the number of characters
    la $t1, name_buffer  # Load address of name_buffer
    
validate_name_loop:
    lb $t2, ($t1)  # Load byte from buffer
    beqz $t2, check_name_end  # End of string if byte is 0
    addi $t0, $t0, 1   
    addi $t1, $t1, 1   
    j validate_name_loop

check_name_end:
    # Length should be 3
    li $t3, 3
    bne $t0, $t3, invalid_id  # Branch if length is not 3
    
    # Check if the Test Name matches one of the valid names
    la $a1, test_names   # Load base address of valid_test_names array
    li $t4, 4                  # Number of valid names
    li $t5, 0                  # Index for looping through valid_test_names

    name_loop:
        beq $t5, $t4, invalid_id   # If end of valid_test_names array, invalid name
        la $t6, 4                  # Length of each valid name
        mul $t7, $t5, $t6          # Calculate offset to current valid name
        add $t7, $t7, $a1          # Calculate memory address to compare
        la $t8, 0($t7)             # Load address of current valid name
        la $t9, 0($a0)             # Load address of input Test Name
        li $t6, 0                  # Counter for comparing characters
        
        validate_char_loop:
            lb $t2, 0($t8)        # Load byte from valid name
            lb $t3, 0($t9)        # Load byte from input Test Name
            beqz $t2, valid_name  # End of valid name reached
            bne $t2, $t3, next_name_char  # If characters don't match, check next valid name
            addi $t8, $t8, 1       
            addi $t9, $t9, 1       
            addi $t6, $t6, 1       
            j validate_char_loop

        next_name_char:
            addi $t5, $t5, 1       # Move to next valid name
            j name_loop
      
    
valid_name:
    # Valid test name
    li $v0, 1
    jr $ra      
 
# Function to validate the date format (YYYY-MM)
validate_date_format:
    # Load the address of the date buffer into $a0
    la $a0, date_buffer
    # Check the length of the string
    li $t0, 0      # Counter for the number of characters
    la $t1, date_buffer  # Load address of date_buffer
    
validate_length_loop:
    lb $t2, ($t1)  # Load byte from buffer
    beqz $t2, check_length_end  # End of string if byte is 0 (null terminator)
    addi $t0, $t0, 1   # Increment counter
    addi $t1, $t1, 1   # Move to next byte
    j validate_length_loop

check_length_end:
    # Length should be 7 (YYYY-MM )
    li $t3, 7
    bne $t0, $t3, invalid_date_format  # Branch if length is not 7

    # Check the format of the date
    la $t4, date_buffer  # Load address of date_buffer
    lb $t5, ($t4)        # Load first character (should be digit for YYYY)
    li $t6, 48           # ASCII value for '0'
    li $t7, 57           # ASCII value for '9'
    blt $t5, $t6, invalid_date_format  # Branch if first character is not a digit
    bgt $t5, $t7, invalid_date_format  # Branch if first character is not a digit

    addi $t4, $t4, 5     # Move to the character after '-'
    lb $t5, ($t4)        # Load next character (should be digit for MM)
    blt $t5, $t6, invalid_date_format  # Branch if character is not a digit
    bgt $t5, $t7, invalid_date_format  # Branch if character is not a digit
    
 #   # Check the '-' character
    addi $t4, $t4, -1    # Move back to the '-' character
    li $t5, 45           # ASCII value for '-'
    lb $t6, ($t4)
 #   beq $t6, $t5, valid_date_format  # Branch if character is '-'
    bne $t6, $t5, invalid_date_format  # Branch if character is '-'
 	
 
    # Check if the year is between 1950 and 2025
    la $t0, date_buffer  # Load address of date_buffer
    li $t1, 1950
    li $t2, 2025
    li $t3, 1000
    li $t4, 100
    li $t5, 10
    
    lbu $t6, 0($t0)  # Load first character of year
    subu $t6, $t6, '0'  # Convert from ASCII to integer
    mult $t6, $t3  # Multiply first digit by 1000
    mflo $t6  # Move the result of the multiplication from LO to $t6
    
    lbu $t7, 1($t0)  # Load second character of year
    subu $t7, $t7, '0'  # Convert from ASCII to integer
    mult $t7, $t4  # Multiply second digit by 100
    mflo $t7
    addu $t6, $t6, $t7  # Add first and second digits
    
    lbu $t8, 2($t0)  # Load third character of year
    subu $t8, $t8, '0'  # Convert from ASCII to integer
    mult $t8, $t5  # Multiply third digit by 10
    mflo $t8
    addu $t6, $t6, $t8  # Add result to third digit
    
    lbu $t8, 3($t0)  # Load fourth character of year
    subu $t8, $t8, '0'  # Convert from ASCII to integer
    addu $t6, $t6, $t8  # Add result to fourth digit
    
    blt $t6, $t1, invalid_date_format  # Branch if year < 1950
    bgt $t6, $t2, invalid_date_format  # Branch if year > 2025

    # Check if the month is between 01 and 12
    la $t0, date_buffer  # Load address of date_buffer
    addiu $t4, $t0, 5  # Move to the first character of the month
    li $t5, 1
    li $t6, 12
    lbu $t7, 0($t4)  # Load first character of month
    subu $t7, $t7, '0'  # Convert from ASCII to integer
    mult $t7, $t5  # Multiply first digit by 10
    mflo $t7
    
    lbu $t8, 1($t4)  # Load second character of month
    subu $t8, $t8, '0'  # Convert from ASCII to integer
    addu $t7, $t7, $t8  # Add first and second digits
    blt $t7, $t5, invalid_date_format  # Branch if month < 01
    bgt $t7, $t6, invalid_date_format  # Branch if month > 12
        
valid_date_format:
    # Valid date format
    li $v0, 1
    jr $ra  
    
invalid_date_format:
    # Invalid date format
    li $v0, 0        
    jr $ra
 
validate_float1:

    # Initialize counter for the number of decimal points
    li $t0, 0
    la $t7, float_buffer  # Load address of float_buffer
     la $t1, 0    # counter for decimal point

    validate_loop:
        # Load byte into $t2
        lb $t2, ($t7)
        move $t6, $t2
            # Move the value from $t2 to $a0
        move $a0, $t6

        # If character is null, end of string has been reached
        beqz $t2, end_of_string

        # If character is a decimal point, increment counter
        li $t3, 46   # .
        beq $t2, $t3, increment_counter
        
        # If character is not a digit, go to invalid_number
        li $t4, 48   # 0
        blt $t2, $t4, invalid_number
        li $t5, 57   # 9
        bgt $t2, $t5, invalid_number

        # Go to next character
        addiu $t7, $t7, 1
        j validate_loop

    increment_counter:
        addiu $t7, $t7, 1
        addiu $t1, $t1, 1
        j validate_loop

    end_of_string:
        # If there is more than one decimal point, go to invalid_number
        li $t2, 1
        bgt $t1, $t2, invalid_number

valid_number:
    # Valid number
    li $v0, 1
    jr $ra  
    
    
invalid_number:
    # Invalid number
    li $v0, 0        
    jr $ra

   
add_to_buffer:
    move $s6, $ra
    # Load addresses of buffers
    la $t0, id_buffer
    la $t1, name_buffer
    la $t2, date_buffer
    la $t4, float_buffer

    # Allocate space for the formatted string "id: name, date, result"
    li $v0, 9   # syscall 9 = sbrk
    li $a0, 34  # Total length: 7 (ID) + 2 (": ") + 3 (name) + 2 (", ") + 7 (date) + 2 (", ") + 10 (result) + 1 (null terminator)
    syscall
    move $s1, $v0  # Store the address of the allocated space for formatted string

    la $t3, ($s1)  # Load address of formatted string

# Copy ID to formatted string
copy_id_to_formatted_string:
    lb $t5, ($t0)  # Load byte from ID buffer
    beqz $t5, end_id_copy  # Exit loop if end of ID string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t0, $t0, 1  # Move to next byte in ID buffer
    addi $t3, $t3, 1  # Move to next byte in formatted string
    j copy_id_to_formatted_string

end_id_copy:
    # Add ": " after ID
    li $t5, ':'  # ASCII for ":"
    sb $t5, ($t3)  # Store ":" to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

    li $t5, ' '  # ASCII for " "
    sb $t5, ($t3)  # Store " " to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

# Copy name to formatted string
copy_name_to_formatted_string:
    lb $t5, ($t1)  # Load byte from name buffer
    beqz $t5, end_name_copy  # Exit loop if end of name string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t1, $t1, 1 
    addi $t3, $t3, 1  
    j copy_name_to_formatted_string

end_name_copy:
    # Add ", " after name
    li $t5, ','  # ASCII for ","
    sb $t5, ($t3)  # Store "," to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

    li $t5, ' '  # ASCII for " "
    sb $t5, ($t3)  # Store " " to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

# Copy date to formatted string
copy_date_to_formatted_string:
    lb $t5, ($t2)  # Load byte from date buffer
    beqz $t5, end_date_copy  # Exit loop if end of date string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t2, $t2, 1  # Move to next byte in date buffer
    addi $t3, $t3, 1  # Move to next byte in formatted string
    j copy_date_to_formatted_string

end_date_copy:
    # Add ", " after date
    li $t5, ','  # ASCII for ","
    sb $t5, ($t3)  # Store "," to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

    li $t5, ' '  # ASCII for " "
    sb $t5, ($t3)  # Store " " to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

# Copy result to formatted string
copy_result_to_formatted_string:
    lb $t5, ($t4)  # Load byte from float buffer
    beqz $t5, end_result_copy  # Exit loop if end of result string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t4, $t4, 1  # Move to next byte in result buffer
    addi $t3, $t3, 1  # Move to next byte in formatted string
    j copy_result_to_formatted_string

end_result_copy:
    # Null-terminate the formatted string
    li $t5, 0  # Null terminator
    sb $t5, ($t3)  # Store null terminator to end the string
    # Now the string "id: name, date, result" is in the address $s1
    jal add_to

  
add_to_buffer2:
    move $s6, $ra

    # Load addresses of buffers
    la $t0, id_buffer
    la $t1, name_buffer
    la $t2, date_buffer
    la $t4, float_buffer
    la $t6, float1_buffer

    # Allocate space for the formatted string "id: name, date, result"
    li $v0, 9   # syscall 9 = sbrk
    li $a0, 46  # Total length: 7 (ID) + 2 (": ") + 3 (name) + 2 (", ") + 7 (date) + 2 (", ") + 10 (result) + 1 (null terminator)
    syscall
    move $s1, $v0  # Store the address of the allocated space for formatted string

    # Construct the formatted string "id: name, date, result"
    la $t3, ($s1)  # Load address of formatted string

# Copy ID to formatted string
copy_id_to_formated_string:
    lb $t5, ($t0)  # Load byte from ID buffer
    beqz $t5, end_id_coppy  # Exit loop if end of ID string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t0, $t0, 1  # Move to next byte in ID buffer
    addi $t3, $t3, 1  # Move to next byte in formatted string
    j copy_id_to_formated_string

end_id_coppy:
    # Add ": " after ID
    li $t5, ':'  # ASCII for ":"
    sb $t5, ($t3)  # Store ":" to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string
    li $t5, ' '  # ASCII for " "
    sb $t5, ($t3)  # Store " " to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

# Copy name to formatted string
copy_name_to_formated_string:
    lb $t5, ($t1)  # Load byte from name buffer
    beqz $t5, end_name_coppy  # Exit loop if end of name string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t1, $t1, 1  # Move to next byte in name buffer
    addi $t3, $t3, 1  # Move to next byte in formatted string
    j copy_name_to_formated_string

end_name_coppy:
    # Add ", " after name
    li $t5, ','  # ASCII for ","
    sb $t5, ($t3)  # Store "," to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string
    li $t5, ' '  # ASCII for " "
    sb $t5, ($t3)  # Store " " to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

# Copy date to formatted string
copy_date_to_formated_string:
    lb $t5, ($t2)  # Load byte from date buffer
    beqz $t5, end_date_coppy  # Exit loop if end of date string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t2, $t2, 1  # Move to next byte in date buffer
    addi $t3, $t3, 1  # Move to next byte in formatted string
    j copy_date_to_formated_string

end_date_coppy:
    # Add ", " after date
    li $t5, ','  # ASCII for ","
    sb $t5, ($t3)  # Store "," to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string
    li $t5, ' '  # ASCII for " "
    sb $t5, ($t3)  # Store " " to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

# Copy result to formatted string
copy_result_to_formated_string:
    lb $t5, ($t4)  # Load byte from float buffer
    beqz $t5, end_result1_copy  # Exit loop if end of result string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t4, $t4, 1  # Move to next byte in result buffer
    addi $t3, $t3, 1  # Move to next byte in formatted string
    j copy_result_to_formated_string

end_result1_copy:
    # Add ", " after date
    li $t5, ','  # ASCII for ","
    sb $t5, ($t3)  # Store "," to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string
    li $t5, ' '  # ASCII for " "
    sb $t5, ($t3)  # Store " " to formatted string
    addi $t3, $t3, 1  # Move to next byte in formatted string

# Copy result to formatted string
copy_result2_to_formated_string:
    lb $t5, ($t6)  # Load byte from float buffer
    beqz $t5, end_result2_copy  # Exit loop if end of result string
    sb $t5, ($t3)  # Store byte to formatted string
    addi $t6, $t6, 1  # Move to next byte in result buffer
    addi $t3, $t3, 1  # Move to next byte in formatted string
    j copy_result2_to_formated_string

end_result2_copy:
    # Null-terminate the formatted string
    li $t5, 0  # Null terminator
    sb $t5, ($t3)  # Store null terminator to end the string
    # Now the formatted string "id: name, date, result" is in the address $s0

add_to:
    # Find the end of the records buffer
    la $t0, records  # Load the base address of the records buffer
    la $t1, 0        # Initialize offset to 0

# Loop to find the end of records
find_end_of_records:
    lb $t2, ($t0)   # Load byte from the current offset in records
    beqz $t2, end_find_records  # If byte is 0 (null terminator), end of records reached
    addi $t0, $t0, 1  # Move to the next byte
    addi $t1, $t1, 1  # Increment the offset
    j find_end_of_records

end_find_records:

    # Now copy the string from $s1 to the end of records
    la $t2, ($s1)   # Load address of the string in $s1
    move $t3, $t0   # Copy the end of records address to $t3

    # Append a newline character to the end of records
    li $t4, 10   # ASCII value for newline
    sb $t4, ($t3)  # Store the newline character to the end of records
    addi $t3, $t3, 1  # Move to the next byte of records

copy_string_to_records:
    lb $t4, ($t2)  # Load byte from the current position of the string
    sb $t4, ($t3)  # Store the byte to the end of records
    beqz $t4, end_copy_string  # If byte is 0 (null terminator), end of string
    addi $t2, $t2, 1  # Move to the next byte of the string
    addi $t3, $t3, 1  # Move to the next byte of records
    j copy_string_to_records

end_copy_string:

   move  $ra, $s6
   jr $ra 
   
      
update_test:         
   # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall
    la $s1, records
    
	# Initialize line number to 1
	li $t0, 1  # Line number

	# Print the first line number
	move $a0, $t0  # Move the line number to $a0
	li $v0, 1  # System call code for print_int
	syscall  # Perform the system call

	# Print a ) character
	li $v0, 11  # System call code for print_char
	li $a0, 41  # ASCII value for )
	syscall  # Perform the system call
	# Print a space
    li $v0, 11  # System call code for print_char
 	li $a0, 32  # ASCII value for space
 	syscall  

	# Print the records buffer with line numbers
	la $t1, ($s1)  # Load address of records buffer into $t1

    jal print_records

    li $s0, 0                      # Counter for the number of records
    la $s1, records
    lb $s3, no_of_records  
    la $s4, search_results

    # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall
    
    li $v0, 4
    la $a0, enter_update_line
    syscall   
    
   # Get user choice
    li $v0, 5
    syscall
    move $t6, $v0
    
    # Check if user choice is within the valid range
    blez $t6, invalid_no_line  # Assuming $zero holds the value 0
    bgt $t6, $s3, invalid_no_line    # Assuming $a0 holds the value of no_of_edit
    # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall
    
    la $t2, ($s1)  # Load address of records buffer into $t2
    la $t4,0    # counter for line number
    
find_line_to_update:
    addiu $t4, $t4, 1 
    la $a1, ($s1)       # Load address of the record to be copied
    la $a2, ($s4)       # Load address of the buffer
    beq $t4, $t6,  start_update
     # copy the record to the buffer
    jal copy_record     # Copy the record to the buffer
    la $s4, ($a2)       # Load address of the next record in the buffer
    jal  skip_record_update
    
        
start_update:
    move $s5, $ra
    la $a1, ($s1)       # Load address of the record
    # make the pointer a1 point to the testtype field
    jal point_next_field
    # copy the test type to the name_temp buffer
    la $a2, name_temp
    jal copy_string    
     
    # Load the first byte (second character due to zero-indexing) of the string into $t0
    lb $t0, 1($a0)
    # Check if the test is BPT by the second char
    li $t1, 80         # Load ASCII value of 'P' into $t1
    beq $t0, $t1, update_bpt # If second character is 'P', branch to update_bpt
     
    li $v0, 4
    la $a0, enter_update_result
    syscall 
    
    # Read result from user input
    la $a0, float_temp  # Load address of result into $a0
    li $a1, 9  # Maximum number of characters to read
    li $v0, 8  # syscall 8 = read string
    syscall

    jal replace_newline_with_null # replace the new line with null charachter
 
    jal validate_float1
    beqz $v0, invalid_input # Invalid input
    la $s7, float_temp
    jal string_to_float
    
    # make the pointer a1 point to the result field
    la $a1, ($s1)
    jal point_next_field
    jal point_next_field

    # copy the result to the float buffer
    la $a2, float_buffer
    jal copy_string
    
    la $a0, float_buffer
    la $v0,4
    syscall 
     
    addiu $a1, $a1, 1 # Move to the next byte


la $t0, float_temp   # Load the address of float_temp into $t0

store_byte_loop:  
    lb $t2, 0($t0) 
    sb $t2, ($a1)  # Store the byte to the current position in records
    addiu $t0, $t0, 1  # Move to the next byte 
    addiu $a1, $a1, 1  # Move to the next byte in search_results
    beqz $t2, end_update  # If byte is zero (end of string), end copy
     
    j store_byte_loop
    
	
update_bpt:

    li $v0, 4
    la $a0, enter_update_result1
    syscall 
    
    # Read result from user input
    la $a0, float_temp1  # Load address of result into $a0
    li $a1, 9  # Maximum number of characters to read
    li $v0, 8  # syscall 8 = read string
    syscall

    jal replace_newline_with_null # replace the new line with null charachter
 
    jal validate_float1
    beqz $v0, invalid_input # Invalid input
    la $s7, float_temp1
    jal string_to_float
    
    li $v0, 4
    la $a0, enter_update_result2
    syscall 
    
    # Read result from user input
    la $a0, float_temp2  # Load address of result into $a0
    li $a1, 9  # Maximum number of characters to read
    li $v0, 8  # syscall 8 = read string
    syscall

    jal replace_newline_with_null # replace the new line with null charachter
 
    jal validate_float1
    beqz $v0, invalid_input # Invalid input
    la $s7, float_temp2
    jal string_to_float
    
    # make the pointer a1 point to the result field
    la $a1, ($s1)
    jal point_next_field
    jal point_next_field

    # copy the result to the float buffer
    la $a2, float_buffer
    jal copy_string
    
    la $a0, float_buffer
    la $v0,4
    syscall 
     
    addiu $a1, $a1, 1 # Move to the next byte     

    la $t0, float_temp1   # Load the address of float_temp into $t0
    la $t5, float_temp2   # Load the address of float_temp into $t0


store_byte_loop1:  
    lb $t2, 0($t0) 
    sb $t2, ($a1)  # Store the byte to the current position in records
    beqz $t2, store_byte_loop2  # If byte is zero (end of string), end copy
    addiu $t0, $t0, 1  # Move to the next byte 
    addiu $a1, $a1, 1  # Move to the next byte in search_results
     
    j store_byte_loop1
    
store_byte_loop2:
    li $t4, 44    # Ascii code for ,
    sb $t4, ($a1)
    addiu $a1, $a1, 1
    li $t4, 32    # Ascii code for ,
    sb $t4, ($a1)
    addiu $a1, $a1, 1

end_store:
    lb $t2, 0($t5) 
    sb $t2, ($a1)  # Store the byte to the current position in records
    addiu $t5, $t5, 1  # Move to the next byte 
    addiu $a1, $a1, 1  # Move to the next byte in search_results
    beqz $t2, end_update  # If byte is zero (end of string), end copy
     
    j end_store
     
    
end_update:

    # Check if the records buffer ends with a null terminator
    la $t0, records     # Load address of the start of the records buffer
    li $t1, 0           # Initialize offset to 0

# Loop to find the end of records buffer
find_end_of_records_buffer:
    lb $t2, ($t0)    # Load byte from the current offset in records buffer
    beqz $t2, add_newline  # If byte is 0 (null terminator), end of records buffer reached
    addi $t0, $t0, 1  # Move to the next byte
    addi $t1, $t1, 1  # Increment the offset
    j find_end_of_records_buffer

add_newline:

 # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall

    move $t2, $a1       # Load address of the string in register $a1

copy_string_to_record:
    lb $t3, ($t2)    # Load byte from the current offset in the string  
    beqz $t3, add_null_terminator  # If byte is 0 (null terminator), end of string reached
    sb $t3, ($t0)    # Store byte to the end of records buffer
    addi $t0, $t0, 1  # Move to the next byte in records buffer
    addi $t2, $t2, 1  # Move to the next byte in the string
    j copy_string_to_record

add_null_terminator:
    li $t3, 0               # Null terminator
    sb $t3, ($t0)  
     
    # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall

# After the loop, the line has been deleted from the search_results buffer    
    li $v0, 4
    la $a0, records
    syscall     
    

 # Write new test to file
    li $v0, 13            # syscall 15 = file status.  The status system call is used to obtain information about a file, such as its size, permissions, and other attributes.
    la $a0, test_file     # file name
    li $a1, 1 # flags are 0: reading, 1: writing
    li $a2, 0 # mode is ignored
    syscall
    move $s0, $v0
   
    li $v0, 15         # syscall 15 = write
    move $a0, $s0      # file descriptor
    la $a1, records

    la $a2,32000	# length of the toWrite string
    move $a3, $s3      # Test Date
    
    syscall

 #   Close file
    li $v0, 16         # syscall 16 = close
    move $a0, $s0      # file descriptor
    syscall
  
    # Print success message
    li $v0, 4
    la $a0, test_updated
    syscall
    
    j display_menu
                
skip_record_update:
    addi $s0, $s0, 1  # Increment counter
    beq $s0, $s3, end_update  # End of records
    la $a1, ($s1)  # Load address of the record
    jal point_next_record  # Move to the next record
    la $s1, ($a1)  # Load address of the next record

    b find_line_to_update 
   
   
delete_test:
    # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall
    la $s1, records
    
    # $s1 is the address of the records buffer
    # Initialize line number to 1
    li $t0, 1  # Line number

    # Print the first line number
    move $a0, $t0  # Move the line number to $a0
    li $v0, 1  # System call code for print_int
    syscall  # Perform the system call

    # Print a ) character
    li $v0, 11  # System call code for print_char
    li $a0, 41  # ASCII value for )
    syscall  # Perform the system call
    # Print a space
    li $v0, 11  # System call code for print_char
    li $a0, 32  # ASCII value for space
    syscall  

    # Print the records buffer with line numbers
    la $t1, ($s1)  # Load address of records buffer into $t1

	jal print_records

    li $s0, 0                      # Counter for the number of records
    la $s1, records
    lb $s3, no_of_records  
    la $s4, search_results

    # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall
    
    li $v0, 4
    la $a0, enter_delete_line
    syscall   
    
   # Get user choice
    li $v0, 5
    syscall
    move $t6, $v0
    
    # Check if user choice is within the valid range
    blez $t6, invalid_no_line  # Assuming $zero holds the value 0
    bgt $t6, $s3, invalid_no_line    # Assuming $a0 holds the value of no_of_edit
    # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall
    
    la $t2, ($s1)  # Load address of records buffer into $t1
    la $t4,0    # counter for line number

find_line_to_delete:
    addiu $t4, $t4, 1 
    la $a1, ($s1)       # Load address of the record to be copied
    la $a2, ($s4)       # Load address of the buffer
    beq $t4, $t6,  skip_record
    # copy the record to the buffer
    jal copy_record     # Copy the record to the buffer
    la $s4, ($a2)       # Load address of the next record in the buffer
    jal  skip_record
   
    
start_delete:
    
    la $s1, records
    la $s4, search_results
    # Clear the records buffer
    la $t0, ($s1)  # Load address of records buffer into $t0

clear_records:
    sb $zero, 0($t0)  # Store zero to the current position in records
    addiu $t0, $t0, 1  # Move to the next byte in records
    lb $t1, 0($t0)  # Load byte from records buffer
    bnez $t1, clear_records  # If byte is not zero, continue clearing

    # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall
	li $v0, 4
    la $a0, test_deleted
    syscall

    # Copy the data from search_results to records
    la $t0, ($s1)  # Load address of records buffer into $t0
    la $t1, ($s4)  # Load address of search_results buffer into $t1

copy_search_results_to_records:
    lb $t2, 0($t1)  # Load byte from search_results buffer
    sb $t2, 0($t0)  # Store the byte to the current position in records
    beqz $t2, end_clear  # If byte is zero (end of string), end copy
    addiu $t0, $t0, 1  # Move to the next byte in records
    addiu $t1, $t1, 1  # Move to the next byte in search_results
    j copy_search_results_to_records

end_clear:
# After the loop, the data in records has been replaced with the data from search_results
    # Print a newline character
    li $v0, 11             # syscall 11 = print character
    li $a0, 0xA            # ASCII value for newline character
    syscall
    li $v0, 4		# print string syscall code = 4
	la $a0, records
	syscall
    
#    # Write new test to file
    li $v0, 13            # syscall 15 = file status.  The status system call is used to obtain information about a file, such as its size, permissions, and other attributes.
    la $a0, test_file     # file name
    li $a1, 1 # flags are 0: reading, 1: writing
    li $a2, 0 # mode is ignored
    syscall
    move $s0, $v0
   
    li $v0, 15         # syscall 15 = write
    move $a0, $s0      # file descriptor
    la $a1, records

    la $a2,32000	# length of the toWrite string
    move $a3, $s3      # Test Date
    
    syscall

    # Close file
    li $v0, 16         # syscall 16 = close
    move $a0, $s0      # file descriptor
    syscall
    
    j display_menu


skip_record:

    addi $s0, $s0, 1  # Increment counter
    beq $s0, $s3, start_delete  # End of records
    la $a1, ($s1)  # Load address of the record
    jal point_next_record  # Move to the next record
    la $s1, ($a1)  # Load address of the next record

    b find_line_to_delete

invalid_no_line:

    # print invalid input
    la $a0, invalid
    li $v0, 4
    syscall
    
    j display_menu  
   
   
calc_no_of_record:
   # count the number of records in the file
    la $t0, search_results
    li $t3, 0           # counter for the number of records
   
count_records_for_change:
    lbu $t4, ($t0)
    beqz $t4, endCount_records
    bne $t4, 0xA, increment
    addi $t3, $t3, 1    # increment record counter
   
increment:
    addi $t0, $t0, 1
    j count_records_for_change

endCount_records:
	addi $t3, $t3, 1
    sb $t3, no_of_edit  # store the number of records
    jr $ra
   
print_records:
    lb $t2, 0($t1)  # Load byte from records buffer
    beqz $t2, end_print  # If byte is zero (end of buffer), end print
    beq $t2, 10, print_line_number  # If byte is newline (ASCII 10), print line number
    move $a0, $t2  # Move the byte to $a0
    li $v0, 11  # System call code for print_char
    syscall  # Perform the system call
    j next_byte  

print_line_number:
    # Print a newline character
    li $v0, 11  # System call code for print_char
    li $a0, 10  # ASCII value for newline
    syscall  # Perform the system call

    addiu $t0, $t0, 1  # Increment the line number

    # Print the line number
    move $a0, $t0  # Move the line number to $a0
    li $v0, 1  # System call code for print_int
    syscall  # Perform the system call

    # Print a colon character
    li $v0, 11  # System call code for print_char
    li $a0, 41  # ASCII value for colon
    syscall  # Perform the system call
    
    # Print a space
    li $v0, 11  # System call code for print_char
    li $a0, 32  # ASCII value for space
    syscall  

next_byte:
    addiu $t1, $t1, 1  # Move to the next byte in records
    j print_records

end_print:
	jr $ra   

#=======================================================================================================      
# Function to convert an unsigned string to a positive float
string_to_float:
    # Initialize variables
    la $a0, ($s7)  # Load address of result into $a0
    l.s $f0, zeroFloat     # Initialize result to 0.0
    l.s $f1, point1     # Initialize decimal multiplier to 0.1
    li $t2, 0         # Initialize flag for decimal point
    l.s $f2, ten

    # Loop through each character of the string
    loop_string_to_float:
        lb $t0, ($a0)    # Load byte from buffer
        beqz $t0, end_float  # End of string reached

        # Check for decimal point
        beq $t0, '.', set_float_decimal_point
        j process_float_character
        

    set_float_decimal_point:
        li $t2, 1        # Set flag for decimal point
        j continue_conversion

    process_float_character:
        # Convert ASCII character to integer
        sub $t1, $t0, '0'  # Convert character to integer

        # Multiply current result by 10 to shift left
        mul.s $f0, $f0, $f2

        # Add the current integer value
        mtc1 $t1, $f12   # Move integer to $f12
        cvt.s.w $f12, $f12   # Convert integer to float
        add.s $f0, $f0, $f12  # Add to the result

        # If decimal point encountered, start multiplying by 0.1 for decimal values
        beq $t2, 1, multiply_decimal_value
        j continue_conversion

    multiply_decimal_value:
        mul.s $f0, $f0, $f1   # Multiply by 0.1 for decimal value

    continue_conversion:
        addi $a0, $a0, 1   # Move to the next character
        j loop_string_to_float

    end_float:
        jr $ra

  
#================================================================
# Function to copy one record from the test file to another memory location
# and stop reading if found new line charachter "\n"

copy_record:
    lbu $t9, 0($a1)   # load byte from source
    sb $t9, 0($a2)    # store byte in destination
    addiu $a1, $a1, 1 # increment source pointer
    addiu $a2, $a2, 1 # increment destination pointer
    beq $t9,'\n', end_copy_record    # if end of string, done
    beq $t9, $zero, end_copy_record  # if null terminator, done
 
    j copy_record     # repeat

end_copy_record:
    sb $zero, 0($a2)  # store null terminator
    jr $ra


#======================================================================
# function to make the pointer a1 point to the next record of the array according to \n
point_next_record:
	lbu $t0, ($a1)
	addi $a1, $a1, 1
    beq $t0, '\0', end_point_next_record #check if reached the end of the string
	bne $t0, '\n', point_next_record #check if reached the end of the string
end_point_next_record:
	jr $ra


#======================================================================
# Function to make the pointer a1 point to the next field of the record according to ',' or ':'
point_next_field:
    lbu $t0, ($a1)
    addi $a1, $a1, 1

    beq $t0, ',', end_point_next_field #check if reached the end of the string
    beq $t0, ':', end_point_next_field #check if reached the end of the string
    bne $t0, '\n', point_next_field #check if reached the end of the string
end_point_next_field:
    jr $ra

#================================================================
# Function to check if the Hemoglobin (Hgb) is within normal range
# $v0 = (1 if abnormal, 0 if normal)
check_Hgb:
   # Check if Hemoglobin (Hgb) is within normal range
    l.s $f0, HGB_MIN
    l.s $f1, HGB_MAX
    c.lt.s $f12, $f0
    bc1t Hgb_abnormal   
    c.le.s $f12, $f1
    bc1t Hgb_normal
    j Hgb_abnormal

Hgb_abnormal:
    li $v0, 1
    jr $ra

Hgb_normal:
    li $v0, 0
    jr $ra


#================================================================
# Function to check if the Blood Glucose Test (BGT) is within normal range
# $v0 = (1 if abnormal, 0 if normal)
check_BGT:
    # Check if Blood Glucose Test (BGT) is within normal range
    l.s $f0, BGT_MIN
    l.s $f1, BGT_MAX
    c.lt.s $f12, $f0
    bc1t BGT_abnormal
    c.le.s $f12, $f1
    bc1t BGT_normal
    j BGT_abnormal

BGT_abnormal:
    li $v0, 1
    jr $ra

BGT_normal:
    li $v0, 0
    jr $ra

#================================================================
# Function to check if the LDL Cholesterol Low-Density Lipoprotein (LDL) is within normal range
# $v0 = (1 if abnormal, 2 if normal)
check_LDL:
    # Check if LDL Cholesterol Low-Density Lipoprotein (LDL) is within normal range
    l.s $f0, LDL_MAX
    c.lt.s $f12, $f0
    bc1t LDL_normal
    j LDL_abnormal

LDL_abnormal:
    li $v0, 1
    jr $ra

LDL_normal:
    li $v0, 2
    jr $ra

#================================================================
# Function to check if the Blood Pressure Test (BPT) is within normal range
# $v0 = (1 if abnormal, 0 if normal)
check_BPT:
    # Check if Blood Pressure Test (BPT) is within normal range
    l.s $f0, BPT_SYS_MAX
    l.s $f1, BPT_DIA_MAX
    c.lt.s $f7, $f0
    bc1t BPT_abnormal
    c.lt.s $f8, $f1
    bc1t BPT_abnormal
    j BPT_normal

BPT_abnormal:
    li $v0, 1
    jr $ra

BPT_normal:
    li $v0, 0
    jr $ra

#===============================================================
# Function strings_isEqual: check if two strings are equal or not with case insensitivity
# $v0 = (1 if equals, 0 if not)
strings_isEqual:
    add $t0, $zero, $zero   # initialize counter to 0
loop_si:
    lbu $t1, ($a0)          # load byte from s1
    lbu $t2, ($a1)          # load byte from s2
    beq $t1, $zero, done    # end of s1
    beq $t2, $zero, done    # end of s2
    addiu $t0, $t0, 1       # increment counter
    addi $a0, $a0, 1        # increment pointer for s1
    addi $a1, $a1, 1        # increment pointer for s2
    andi $t1, $t1, 0xDF     # convert t1 to uppercase (ASCII code)
    andi $t2, $t2, 0xDF     # convert t2 to uppercase (ASCII code)
    bne $t1, $t2, not_equal # case-insensitive comparison
    j loop_si
not_equal:
    add $v0, $zero, 0       # set return value to 0
    jr $ra
done:
    beq $t1, $t2, equal     # s1 and s2 have the same length
    add $v0, $zero, 0       # set return value to 0
    jr $ra
equal:
    add $v0, $zero, 1       # set return value to 1
    jr $ra
    
#====================================================================
# function to replace the newline character with null terminator
replace_newline_with_null:
    # loop through the buffer
loop_rnwn:
    lbu $t0, ($a0)       # load byte at current offset
    beq $t0, '\n', end    # exit loop if newline found
    beq $t0, $zero, end  # exit loop if null terminator is reached
    addi $a0, $a0, 1     # increment buffer address
    j loop_rnwn

    # replace the newline with null terminator
end:
    sb $zero, ($a0)      # replace newline with null terminator
    jr $ra               # return from the function
     
     
#================================================================
# Function to copy string from memory location to another memory location
# inputs : a1 : the address of the string to be copied
#		   a2 : the address of the destination memory location
# the string stored the destination memory location
copy_string:
    lbu $t9, 0($a1)   # load byte from source
    beq $t9,'\r', end_copy    # if end of string, done
    beq $t9,'\0', end_copy
    beq $t9,':', end_copy
    beq $t9,',', end_copy
    beq $t9,' ', skip_space_copy
    sb $t9, 0($a2)    # store byte in destination
    addiu $a2, $a2, 1 # increment destination pointer
skip_space_copy:
    addiu $a1, $a1, 1 # increment source pointer
    j copy_string     # repeat

end_copy:
    sb $zero, 0($a2)  # store null terminator
    jr $ra


#=======================================================================================================
# Function to check the test type if it is Hgb, BGT, LDL, or BPT
# $v0 = 1 if Hgb, 2 if BGT, 3 if LDL, 4 if BPT
check_test_type:
    # save the return address
    sw $ra, 4($sp)  

    # Hgb
    la $a0, name_buffer
    la $a1, HBG_string
    jal strings_isEqual
    beq $v0, 1, test_is_Hgb
    # BGT
    la $a0, name_buffer
    la $a1, BGT_string
    jal strings_isEqual
    beq $v0, 1, test_is_BGT
    # LDL
    la $a0, name_buffer
    la $a1, LDL_string
    jal strings_isEqual
    beq $v0, 1, test_is_LDL
    # BPT
    la $a0, name_buffer
    la $a1, BPT_string
    jal strings_isEqual
    beq $v0, 1, test_is_BPT

test_is_Hgb:
    li $v0, 1
    lw $ra, 4($sp)
    jr $ra

test_is_BGT:
    li $v0, 2
    lw $ra, 4($sp)
    jr $ra

test_is_LDL:
    li $v0, 3
    lw $ra, 4($sp)
    jr $ra

test_is_BPT:
    li $v0, 4
    lw $ra, 4($sp)
    jr $ra


#=======================================================================================================
# Function to convert the date from the form of yyyy-mm to yyyymm
convert_date:
    lb $t0, 5($a0)  # Load the first character of the month
    sb $t0, 4($a0)  # Store the first character of the month in the fourth character of the year
    lb $t0, 6($a0)  # Load the second character of the month
    sb $t0, 5($a0)  # Store the second character of the month in the fifth character of the year
    sb $zero, 6($a0)  # Store the null terminator in the sixth character of the year
    jr $ra


#=======================================================================================================
# Funtion to convert string to integer
atoi:
    # Initialize result to 0
    li $v0, 0
    
atoi_loop:
    lb $t0, 0($a0)        # Load byte from string into $t0
    beqz $t0, done_atoi   # If byte is null terminator, exit loop
    sub $t0, $t0, 48      # Convert ASCII digit to integer
    mul $v0, $v0, 10      # Multiply current result by 10
    add $v0, $v0, $t0     # Add current digit to result
    addi $a0, $a0, 1      # Move to next character in string
    j atoi_loop           # Repeat loop
    
done_atoi:
    jr $ra                # Return from function
