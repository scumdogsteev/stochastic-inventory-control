{This is the code for Phase II, Part A.
by Steev
2003.04.02

This code is distributed with NO LICENSE.  If it messes up your computer, don't blame me.

This should compile in a Turbo Pascal compiler, if you can find one.}
program exam2_phase2;
uses
    wincrt;
var             {global variables}
     S, lambda, n: Integer; {the variable parameters of the problem}
     P: Array[0..87,0..87] of Real; {Turbo Pascal will not allow a variable-sized array; thus, the upper limit of S is 87}
     rsubk,rsubkay, sum: Real;
     lst: text;

{the following procedures and functions relate to the display of output}
procedure OUTPUT_SELECTION; {this procedure sends output to the screen or to the printer}
    var
        CHOICE:char;
    begin
        writeln;
        writeln('Do you wish to send output to the (S)creen or (P)rinter?');
        repeat
            CHOICE:=readkey;
            if(CHOICE='S')or(CHOICE='s') then
                assigncrt(LST)
            else
                assign(LST,'LPT1');
            rewrite(LST);
        until CHOICE in ['S','s','P','p'];
    end;


procedure center(line:string); {this procedure centers a line of text on the screen}
          var
             tab,len:integer;
          begin
               len:=length(line);
               tab:=(78-len) div 2;
               writeln(' ':tab,line);
          end;

procedure centerf(var fil:text; line:string);{this procedure centers a line of text on the page}
var
   tab,
   len:integer;
begin
   len:=length(line);
   tab:=(78-len)div 2;
   writeln(fil,' ':tab,line);
end;

procedure header;
          begin
               clrscr;
               writeln(lst);
               writeln(lst);
               centerf(lst,'IE 5331 - Stochastic Processes');
               centerf(lst,'Exam II, Phase II, Part A');
               writeln(lst);
               writeln(lst);
          end;

{the following functions provide mathematical operations, x^y and n factorial, since these are not built into Turbo Pascal}
function power(base,exp:integer):integer; {this function computes a number raised to the power of another number, base^exp}
          var
             temp,lcv:integer;   {this only works for integers, but that is all that are applicable to the problem}
          begin
               if exp=0 then
                  power:=1
               else
                   begin
                        temp:=base;
                        for lcv:= 2 to exp do
                            temp:=temp*base;
                            power:=temp;
                   end;
          end;

function factorial(n: integer): integer; {this function returns the factorial of n (n!)}
          begin
               if n=0 then
                  factorial:=1
               else
                  factorial:=n*factorial(n-1);
          end;

{the following procedures are the actual focus of the program}
procedure get_values; {reads the value of S from the keyboard}
          begin
               center('This will generate the one-step transition matrix for a passed value of S.');
               center('The number of weeks and the rate of the Poisson arrival process are also');
               center('variables.');
               writeln;
               writeln('The following values must be integers.');
               writeln;
               write('Enter the value of S (must be an integer <= 87):  ');
               readln(S);
               writeln;
               write('Enter the value of lambda, the rate of the Poisson arrival process:  ');
               readln(lambda);
               writeln;
               write('Enter the value of n (number of weeks):  ');
               readln(n);
               writeln;
          end;

procedure transition; {this procedure calculates P, the one-step transition matrix - this is Part A}
          var
             i,j,dummy: Integer;
          begin
               sum:=0;
               for j:=4 to S-1 do {this loop calculates p(k) for rows 4 to S-1}
                  begin
                       P[S,j]:=0;
                       for i:=1 to S-1 do
                           P[i,j]:=exp(-lambda*n)*power(lambda*n,i-1)/factorial(i-1);
                  end;
               for i:=S downto 0 do
                   P[i,S]:=exp(-lambda*n)*power(lambda*n,i)/factorial(i); {this loop calculates p(k) for row S}
               for j:=3 downto 0 do {this loop calculates p(k) for rows 0 to 3}
                  begin
                       for i:=S downto 0 do    
                           begin
                                P[i,j]:=exp(-lambda*n)*power(lambda*n,i)/factorial(i); {calculation of p(k)}
                           end;
                  end;
               sum:=0;
               for j:=1 to S-1 do
                   sum:=P[j,0]+sum;
               rsubk:=1-sum-P[0,0]; {calculation of r(k) for rows 1 to S-1 (r(k) = 1 - sum - p(0)}
               for j:=3 downto 0 do {this loop assigns r(k) to the first column in rows 0 to 3}
                  begin
                       P[S,j]:=rsubk;
                  end;              
               sum:=0;
               for j:=4 to S-1 do {this loop recalculates r(k) for rows 4 to S-1 and assigns r(k) to their first columns}
                  begin
                       sum:=0;
                       for i:=1 to S do
                           sum:=P[i,j]+sum;
                       rsubkay:=1-sum-P[0,S-1]; {calculation of r(k) for rows 4 to S-1} 
                       P[S,j]:=rsubkay;
                  end;
               P[S,S]:=rsubk; {r(k) for row S = r(k) for rows 0 to 3}
          end;

procedure print_trans; {this procedure prints P, the one-step transition matrix}
          var
             i,j: Integer;
          begin
               centerf(lst,'The One-Step Transition Matrix, P, is as follows:');
               writeln(lst);
               for j:=0 to S do
                   begin
                        for i:=S downto 0 do
                            begin
                                 write(lst,'  ',P[i,j]:0:5)
                            end;
                        writeln(lst);
                   end;
               writeln(lst);
               writeln(lst,'  S = ',S,', the rate of the Poisson arrival process = ',lambda,',');
               writeln(lst,'  and the number of weeks is ',n,'.');
          end;

{the following code is the actual program}
begin
     get_values;
     output_selection;
     transition;
     header;
     print_trans;
end.