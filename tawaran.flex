/**
   To use this scanner on your PDF file, first open your PDF file. 
   Ctrl+A to select all words in the PDF file.
   Ctrl+C to copy all the words.
   Open notepad (or any text editor you prefer.) and raw paste it. (Ctrl+Shift+V)
   Save it as .txt format.
   Then use the .txt file as input for the scanner.
   
   WARNING: This scanner relies on newline characters to extract data. 
   Make sure your paste contains newline. MS Word tends to remove newlines if you paste normally.
   This is why raw paste is recommended.
   Unfortunately that also means if there is a line break in the middle of the information, there will be dropped data.
   So far the only way to fix it is to delete the line breaks manually.
   Otherwise it will render the scanner inflexible to changes in the document structure.
*/

%%

%public
%class tawaran
%standalone

%line
%char
%unicode

// Allows saving different matches into one token/output.
%{
      StringBuffer string = new StringBuffer();
%}

Digit = [1-9]
DigitZero = {Digit}|0
Year = {Digit}{DigitZero}{DigitZero}{DigitZero}
Separator = ("/"|"-")

// Note: Order of occurence is consistently Date -> (optional address) Name -> Rest of the document.
Date = "Date : "|"Tarikh : "
StudentAddr = "SDRI "|"SDR "

FacultyHead = "FAKULTI : "|"FACULTY : "

CourseHead = "PROGRAM PENGAJIAN : "|"PROGRAMME OF STUDY : "

SessionHead = "SESI AKADEMIK "|"ACADEMIC SESSION "
Session = {Year}{Separator}{Year}

TuitionHead = "YURAN KEMASUKAN : "|"TUITION FEE : "
Tuition = "RM "(({Digit}{DigitZero}?{DigitZero}?(,{DigitZero}{DigitZero}{DigitZero})*)|0)"."{DigitZero}{DigitZero}

%state DATE
%state STUDENTHEAD
%state STUDENT
%state FACULTY
%state COURSE
%state SESSION
%state TUITION

%%

<YYINITIAL>{
	{Date}			{ string.setLength(0); yybegin(DATE); } //Reasoning. Date -> Student name -> rest of the document
	{FacultyHead}	{ string.setLength(0); yybegin(FACULTY); }
	{CourseHead}	{ string.setLength(0); yybegin(COURSE); }
	{SessionHead}	{ yybegin(SESSION); } // works
	{TuitionHead}	{ yybegin(TUITION); } // works
	[^]				{  }
}

<DATE>{
	\n				{ yybegin(STUDENTHEAD); }
}

<STUDENTHEAD>{
	{StudentAddr}	{ yybegin(STUDENT); } //consume the address string
	[^]				{ string.append(yytext()); yybegin(STUDENT); }
}

<STUDENT>{
	//{Student}		{ System.out.println("Student Name: " + yytext()); yybegin(YYINITIAL); }
	\n				{ yybegin(YYINITIAL); System.out.println("Student Name: " + string.toString()); }
	[^\n\r\"\\]+	{ string.append(yytext()); }
}

<FACULTY>{
	//{Faculty}		{ System.out.println("Faculty: " + yytext()); yybegin(YYINITIAL); }
	\n				{ yybegin(YYINITIAL); System.out.println("Faculty: " + string.toString()); }
	[^\n\r\"\\]+	{ string.append(yytext()); }
}

<COURSE>{
	//{Course}		{ System.out.println("Program of Study: " + yytext()); yybegin(YYINITIAL); }
	\n				{ yybegin(YYINITIAL); System.out.println("Program of Study: " + string.toString()); }
	[^\n\r\"\\]+	{ string.append(yytext()); }
}

<SESSION>{
	{Session}	{ System.out.println("Start Session: " + yytext()); yybegin(YYINITIAL); }
}

<TUITION>{
	{Tuition}	{ System.out.println("Tuition Fee: " + yytext()); yybegin(YYINITIAL); }
}