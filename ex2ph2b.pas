{This is the code for Phase II, Part B.}
program exam2_phase2;
uses
    wincrt;

const
S=5;
lambda=4;
n=1;

var             {global variables}
{     S, lambda, n: Integer; {the variable parameters of the problem}
     P: Array[0..87,0..87] of Real; {Turbo Pascal will not allow a variable-sized array; thus, the upper limit of S is 87}
     Pi: Array[0..S,0..S] of Real;
     jacobi_n: integer; {the number of Jacobi iterations needed to satisfy the problem}
     loopcv, loopcv2: integer;
     rsubk, rsubkay, sum: Real;
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
               centerf(lst,'Exam II, Phase II, Part B');
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

procedure transition; {this procedure calculates P, the one-step transition matrix - this is Part A}
          var
             i,j: Integer;
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

procedure print_jacobi; {this procedure prints the equilibrium probabilities for each Jacobi iteration}
          var
             i:integer;
          begin
                    begin
                    if jacobi_n = 0 then
                       begin                                      
                            write(lst,'Iter.',jacobi_n:2,': ','Pi = [');
                            write(lst,' ',Pi[0,jacobi_n]:0:6);
                            for i:=1 to S do
                                write(lst,' ',Pi[i,jacobi_n]:0:6);
                                writeln(lst,' ]');
                       end
                    else
                       begin
                            write(lst,'Iter.',jacobi_n:2,': ','Pi = [');
                            for i:=S downto 0 do
                                write(lst,' ',Pi[i,jacobi_n]:0:6);
                            writeln(lst,' ]');
                       end;
                    end;     
          end;


procedure jacobi; {this procedure performs the Jacobi iterations to calculate the equilibrium probabilities}
          var
             i,j:integer;
             check:boolean;
          begin
               check:=False;
               Pi[0,0]:=1.0;
               for j:=1 to S do
                   Pi[0,j]:=0.0;
               print_jacobi;
               inc(jacobi_n);
               for j:=0 to S do
                     Pi[j,jacobi_n]:=P[j,0];
               print_jacobi;
               inc(jacobi_n);
               repeat
                   inc(jacobi_n);
                   for j:=0 to S do
                       begin
                            for i:=0 to S do
                                Pi[j,jacobi_n]:=Pi[i,jacobi_n-1]*P[j,i]+Pi[j,jacobi_n];
                       end;
                       print_jacobi;
                       if ((Pi[i,jacobi_n]-Pi[i,jacobi_n-1]) <= 0.0001) then check:=True
                       else check:=False;
               until check = True;

          end;

{the following code is the actual program}
begin
     output_selection;                    
     transition;
     header;
     jacobi;
     writeln(lst);
     writeln(lst,'For the problem with S = ',S,', Lambda = ',lambda,', and number of weeks = ',n,', it takes ',jacobi_n);
     writeln(lst,'iterations to achieve equilibrium probabilities that have less than 0.0001');
     writeln(lst,'difference between iterations.');
end.