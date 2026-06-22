InstallKeybdHook 
; Requirements:
; * Autohotkey v2

; * Create a CSV file C:\backup\data.csv Example: https://raw.githubusercontent.com/freeload101/SCRIPTS/refs/heads/master/AutoHotkey/data.csv
; * Make sure the date,zip code is all correct and you don't have any required fields with wrong info! example date format 11/12/25 insted of 11/21/2025 or zip code of 9333 insted of 09333
; * Open and for the field "Select the Week Ending Date of your work search" select the date range you like to submit 
; * Press F2 to run the macro! 

; Issues:
; Video: https://youtu.be/LMj0pwGzVrE 
; Report https://github.com/freeload101/SCRIPTS/issues/new?template=bug_report.md
; Make sure your State code or State full name is correct
; Make sure your City name is correct
; Be sure you have no commas in your text


SendCsv(row) {

; Specify the delay between typing each field (in milliseconds)
delayBetweenFields := 500

; goto first field
send "{ctrl down}f{ctrl up}"
sleep delayBetweenFields
send "for the Week Ending Date"
sleep delayBetweenFields
send "{esc}"
sleep delayBetweenFields
send "{tab}"
sleep delayBetweenFields


	; Specify the path to the CSV file
	csvFilePath := "C:\backup\data.csv"
	; Specify the row number to read (1-based index)
	rowNumber := row


	; Function to read a specific row from a CSV file
	ReadCsvRow(filePath, rowNum) {
		file := FileOpen(filePath, "r")
		if !IsObject(file) {
			MsgBox "Could not open file: " filePath
			return false
		}

		row := 1
		while !file.AtEOF
		{
			line := file.ReadLine()
			if (row = rowNum) {
				file.Close()
				return StrSplit(line, ",")
			}
			row++
		}

		file.Close()
		MsgBox "Row number " rowNum " not found in file."
		return false
	}

	; Main script execution
	row := ReadCsvRow(csvFilePath, rowNumber)

	if IsObject(row) {


		; Loop through each field in the row and type it
		for index, field in row
		{
		
		; Define the state codes table
	stateCodes := Map(
		"Alabama", "AL",
		"Alaska", "AK",
		"Arizona", "AZ",
		"Arkansas", "AR",
		"California", "CA",
		"Colorado", "CO",
		"Connecticut", "CT",
		"Delaware", "DE",
		"District of Columbia", "DC",
		"Florida", "FL",
		"Georgia", "GA",
		"Hawaii", "HI",
		"Idaho", "ID",
		"Illinois", "IL",
		"Indiana", "IN",
		"Iowa", "IA",
		"Kansas", "KS",
		"Kentucky", "KY",
		"Louisiana", "LA",
		"Maine", "ME",
		"Maryland", "MD",
		"Massachusetts", "MA",
		"Michigan", "MI",
		"Minnesota", "MN",
		"Mississippi", "MS",
		"Missouri", "MO",
		"Montana", "MT",
		"Nebraska", "NE",
		"Nevada", "NV",
		"New Hampshire", "NH",
		"New Jersey", "NJ",
		"New Mexico", "NM",
		"New York", "NY",
		"North Carolina", "NC",
		"North Dakota", "ND",
		"Ohio", "OH",
		"Oklahoma", "OK",
		"Oregon", "OR",
		"Pennsylvania", "PA",
		"Puerto Rico", "PR",
		"Rhode Island", "RI",
		"South Carolina", "SC",
		"South Dakota", "SD",
		"Tennessee", "TN",
		"Texas", "TX",
		"Utah", "UT",
		"Vermont", "VT",
		"Virginia", "VA",
		"Virgin Islands", "VI",
		"Washington", "WA",
		"West Virginia", "WV",
		"Wisconsin", "WI",
		"Wyoming", "WY"
	)

	; Replace the value of the variable "field" with the corresponding state code
	for state, code in stateCodes {
		if (field = state) or (field = StrLower(state)) or (field = StrUpper(state)) or (field = StrTitle(state)) {
			field := code
			break
		}
	}
		;for the field "Was this a new or follow up contact? *
		if (field = "New") {
			Send "{space}"
		}
		
		;for the field "Has this business/company offered you a job?  
		if (field = "No Offer") {
			send '{Left}'
			sleep 300
			Send "{space}"
		}
		
		;for the field "Has this business/company offered you a job?  
		if (field = "Yes Offer") {
			Send "{space}"
		}
		
		;for the field Can you provide proof of this contact upon request?  *
		if (field = "Yes Proof") {
			Send "{space}"
		}
		
		;for the field Can you provide proof of this contact upon request?  *
		if (field = "No Proof") {
			send '{Left}'
			sleep 300
			Send "{space}"
		}
		
			
	tooltip field
	sleep 200
			; Remove all CR and LF in one line
			field := StrReplace(StrReplace(field, "`r", ""), "`n", "")

			; Type the field
			SendInput "{Text}" field

			; Delay before typing the next field
			Sleep delayBetweenFields

			; Optionally, add a tab or other separator between fields
			if (index < row.Length) ; Corrected line
				SendInput "{Tab}"
		}
	}

}
 
 
F2::{

;Submit row 2
SendCsv("2")

SendInput "{Tab}"
sleep 300
Send "{space}"
sleep 5000

tooltip "Submited Activity 1 !"


; Submit Row 3
SendCsv("3")
SendInput "{Tab}"
sleep 300
Send "{space}"
sleep 5000
tooltip "Submited Activity 2 !"


; Submit Row 4
SendCsv("4")
SendInput "{Tab}"
sleep 300
Send "{space}"
sleep 5000
tooltip "Submited Activity 3 !"


}
