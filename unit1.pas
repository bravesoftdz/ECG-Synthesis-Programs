unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  TAGraph, TASeries, math;

type
  myArray1 = array [0..10000] of extended;
  myArray2 = array [0..5] of extended;
  myArray3 = array [0..500000] of real;
  myArray4 = array [1..3] of extended;

  { TForm1 }

  TForm1 = class(TForm)
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    Chart2LineSeries1: TLineSeries;
    Chart3LineSeries1: TLineSeries;
    Chart3LineSeries2: TLineSeries;
    Chart4LineSeries1: TLineSeries;
    Chart4LineSeries2: TLineSeries;
    Chart5LineSeries1: TLineSeries;
    Run_app: TButton;
    Cls_app: TButton;
    Chart1: TChart;
    Chart2: TChart;
    Chart3: TChart;
    Chart4: TChart;
    Chart5: TChart;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit2: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    Edit22: TEdit;
    Edit23: TEdit;
    Edit24: TEdit;
    Edit25: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    RadioButton1: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    RadioButton13: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    procedure Cls_appClick(Sender: TObject);
    function myidft(in1,in2: myArray1): myArray1;
    function ddiff(t_awal, x_awal, y_awal, z_awal: real; ex: integer): real;
    function ang_speed(in1: real):real;
    function nozerodiv (in1: real):real;
    function modulus(in1, in2: real):real;
    procedure delay(lama: integer);
    procedure r_kuttaorde4;
    procedure down_samp;
    procedure Run_appClick(Sender: TObject);
    procedure p_input;
    procedure processing;
  private

  public

  end;

var
  Form1: TForm1;
  mean, std, zma, zmi, zr, upsamp, ulang_int2: double;
  r, h, i, j, k, jh, fse, isf, hrm, hrstd, rrfs, ulang_int1, bt, bts: integer;
  flo, fhi, flostd, fhistd, lfhf_rat, df, ome_low, ome_hi, rad1, rad2, sig2, sig1, t, rrmean, rrstd, jdrr, hrn1, hrn2  : extended;
  xstd, rat, diff: extended;
  ome, fasran1, fasran2, idft, rsa, mayer, rsa_mayer, mirror: myArray1;
  rr, realVal, imagVal, hasil: myArray1;
  bi, ti, ai: myArray2;
  xf, yf, zf, xt, yt, zt, up_samprr, piecew: myArray3;
  x: myArray4;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.p_input;
begin
  jh       := strtoint(Edit1.Text);     // jumlah heartbeat
  fse      := strtoint(Edit2.Text);     // sampling frequency
  isf      := strtoint(Edit3.Text);     // Internal Sampling Frequency
  hrm      := strtoint(Edit4.Text);     // heart rate mean
  hrstd    := strtoint(Edit5.Text);     // heart rate standart deviation
  flo      := strtofloat(Edit6.Text);   // Frequency low
  fhi      := strtofloat(Edit7.Text);   // Frequency high
  flostd   := strtofloat(Edit8.Text);   // Frequency low standart deviation
  fhistd   := strtofloat(Edit9.Text);   // Frequency high standart deviation
  lfhf_rat := strtofloat(Edit10.Text);  // LF/HF Ratio

  ome_low := 2*pi*flo;
  ome_hi  := 2*pi*fhi;
  rad1    := 2*pi*flostd;
  rad2    := 2*pi*fhistd;
  sig2    := 1;
  sig1    := lfhf_rat;

  rrfs    := 1;
  t       := 1/rrfs;
  rrmean  := 60/hrm;
  rrstd   := 60*hrstd/(sqr(hrm));
  jdrr    := power(2,ceil(log2(jh*rrmean/t)));
  df      := rrfs/jdrr;

  hrn1    := sqrt(hrm/60);
  hrn2    := sqrt(hrn1);

  for i:=1 to 5 do
      bi[i] := bi[i]*hrn1;

  ti[1] := ti[1]*hrn2;
  ti[2] := ti[2]*hrn1;
  ti[3] := ti[3];
  ti[4] := ti[4]*hrn1;
  ti[5] := ti[5]*hrn2;
end;

procedure TForm1.processing;
begin
  //proses rr
  for i:=1 to round(jdrr) do
      ome[i] := (i-1)*2*pi*df;

  for i:=1 to round(jdrr) do
  begin
    mayer[i]     := (sig1)*exp(-0.5*power((ome[i] - ome_low)/rad1,2))/sqrt(2*power(rad1,2)); //gaussian mayer
    rsa[i]       := (sig2)*exp(-0.5*power((ome[i] - ome_hi)/rad2,2))/sqrt(2*power(rad2,2));  //gaussian RSA
    rsa_mayer[i] := rsa[i] + mayer[i];
    Chart1LineSeries1.AddXY(ome[i]/(2*pi),rsa[i]);
    Chart1LineSeries2.AddXY(ome[i]/(2*pi),mayer[i]);
  end;

  //momotong mirror u/ cari IDFT
  for i:=1 to round(jdrr/2) do
      mirror[i] := (rrfs/2)*sqrt(rsa_mayer[i]);

  for i:=round((jdrr/2)+1) to round(jdrr) do
      mirror[i] := (rrfs/2)*sqrt(rsa_mayer[round(jdrr)-i+1]);

  //cari fase random
  for i:=1 to round((jdrr/2)-1) do
      fasran1[i] := 2*pi*random(10)/10;

  fasran2[i] := 0;
  for i:=1 to round((jdrr/2)-1) do
      fasran2[i+1] := fasran1[i];

  fasran2[round(jdrr/2)+1] := 0;
  for i:=1 to round((jdrr/2)-1) do
      fasran2[round(jdrr)-i+1] := -fasran1[i];

  //cari nilai real dan imajiner
  for i:=1 to round(jdrr) do
  begin
    realVal[i] := mirror[i]*cos(fasran2[i]);
    imagVal[i] := mirror[i]*sin(fasran2[i]);
  end;
  rr := myidft(realVal, imagVal);
  for i:=1 to round(jdrr) do
      Chart2LineSeries1.AddXY(i,hasil[i]);

  //cari RR Tachogram
  xstd := stddev(rr);
  rat  := rrstd/xstd;
  for i:=1 to round(jdrr) do
  begin
    rr[i] := rr[i]*rat; // amplitude rr tacho
    //Chart3LineSeries1.AddXY(i,rr[i]);
  end;

  for i:=1 to round(jdrr) do
  begin
    rr[i] := rr[i] + rrmean;
    Chart3LineSeries2.AddXY(i,rr[i]);
  end;

  //upsampling
  r := round(isf);
  for i:=1 to round(jdrr)-1 do
  begin
    for j:=1 to r do
    begin
      upsamp               := (j-1)*1/r;
      up_samprr[(i-1)*r+j] := (1.0 - upsamp)*rr[i] + upsamp*rr[i+1];
      //Chart4LineSeries1.AddXY(((i-1)*r+j),up_samprr[(i-1)*r+j]);
    end;
  end;

  //interpolasi mencari piecewise (u/ mencari parameter angular)
  diff := 1.0/isf;
  i := 1;
  ulang_int2 := 0;
  ulang_int1 := round((jdrr-2)*isf + isf);
  while (i <= ulang_int1) do
  begin
    ulang_int2 := ulang_int2 + up_samprr[i];
    j := round(ulang_int2/diff);
    for h :=i to j do
    begin
      piecew[h] := up_samprr[i];
      Chart4LineSeries2.AddXY(h,piecew[h]);
    end;
    i := j + 1;
  end;
  bt := j;
end;

function TForm1.myidft(in1,in2: myArray1): myArray1;
var
  p,q: integer;
begin
  for p:=1 to round(jdrr) do
  begin
    idft[p] := 0;
    for q:=1 to round(jdrr) do
        idft[p]  := idft[p] + (in1[q]*cos(2*pi*p*q/jdrr)) + (in2[q]*sin(2*pi*p*q/jdrr)) ;
    hasil[p] := idft[p]/jdrr;
  end;
  myidft := hasil;
end;

function TForm1.ddiff(t_awal, x_awal, y_awal, z_awal: real; ex: integer): real;
var
  amp, turune, diffe, diffe2, temp, ampz: real;
  i : integer;
begin
  //3D state space
  amp := 1.0 - sqrt(sqr(x_awal)+sqr(y_awal));
  if (ex = 1)then
     ddiff := amp*x_awal - ang_speed(t_awal)*y_awal    //x dot (kecepatan thdp x)
  else if (ex = 2) then
     ddiff := amp*y_awal + ang_speed(t_awal)*x_awal    //y dot (kecepatan thdp x)
  else
  begin
    temp := 0;
    ampz := 0.005*sin(2*pi*t_awal);
    turune := arctan2(y_awal,x_awal);
    for i:=1 to 5 do
    begin
      diffe := modulus(turune - ti[i], 2*pi);
      diffe2:= sqr(diffe);
      temp  := temp + -ai[i]*diffe*exp(-0.5*diffe2/sqr(bi[i]));
    end;
    temp := temp - 1.0*(z_awal - ampz);
    ddiff := temp;
  end;
end;

function TForm1.ang_speed(in1: real):real;
var
  i: integer;
begin
  i:= 1 + floor(in1/diff);
  ang_speed := 2.0*pi/nozerodiv(piecew[i]);
end;

function TForm1.nozerodiv (in1: real):real;
begin
  if (in1 = 0) then
    nozerodiv :=  0.000000000001
  else
    nozerodiv := in1;
end;

function TForm1.modulus(in1, in2: real):real;
begin
  while (in1 >= in2) do in1 := in1 - in2;
  modulus := in1;
end;

procedure TForm1.r_kuttaorde4;
var
  wktu : real;
  q1x,q1y,q1z : real;
  q2x,q2y,q2z : real;
  q3x,q3y,q3z : real;
  q4x,q4y,q4z : real;
begin
  //Inisiasi awal
  x[1] := 0.1;     //dari kodingan
  x[2] := 0.0;
  x[3] := 0.04;

  wktu := 0.0;
  for i:= 1 to round(bt) do begin
    xt[i] := x[1];
    yt[i] := x[2];
    zt[i] := x[3];

    //Hitung q1
    q1x := ddiff(wktu,x[1],x[2],x[3],1);    //1 = x, 2 = y, 3 = z (mempermudah proses rungekutta)
    q1y := ddiff(wktu,x[1],x[2],x[3],2);
    q1z := ddiff(wktu,x[1],x[2],x[3],3);

    //Hitung q2
    q2x := ddiff(wktu + df*0.5, x[1] + df*0.5*q1x, x[2] + df*0.5*q1y, x[3] + df*0.5*q1z,1);
    q2y := ddiff(wktu + df*0.5, x[1] + df*0.5*q1x, x[2] + df*0.5*q1y, x[3] + df*0.5*q1z,2);
    q2z := ddiff(wktu + df*0.5, x[1] + df*0.5*q1x, x[2] + df*0.5*q1y, x[3] + df*0.5*q1z,3);

    //Hitung q3
    q3x := ddiff(wktu + df*0.5, x[1] + df*0.5*q2x, x[2] + df*0.5*q2y, x[3] + df*0.5*q1z,1);
    q3y := ddiff(wktu + df*0.5, x[1] + df*0.5*q2x, x[2] + df*0.5*q2y, x[3] + df*0.5*q1z,2);
    q3z := ddiff(wktu + df*0.5, x[1] + df*0.5*q2x, x[2] + df*0.5*q2y, x[3] + df*0.5*q1z,3);

    //Hitung q4
    q4x := ddiff(wktu + df, x[1] + q3x*df, x[2] + q3y*df, x[3] + q3z*df,1);
    q4y := ddiff(wktu + df, x[1] + q3x*df, x[2] + q3y*df, x[3] + q3z*df,2);
    q4z := ddiff(wktu + df, x[1] + q3x*df, x[2] + q3y*df, x[3] + q3z*df,3);

    //Hasil akhir RungeKutta
    x[1] := x[1] + (df/6)*(q1x + 2*q2x + 2*q3x + q4x);
    x[2] := x[2] + (df/6)*(q1y + 2*q2y + 2*q3y + q4y);
    x[3] := x[3] + (df/6)*(q1z + 2*q2z + 2*q3z + q4z);

    wktu := wktu + df;
  end;
end;

procedure TForm1.down_samp;
begin
  i := 1;
  j := 0;
  while (i <= bt) do
  begin
    j := j + 1;
    xf[j] := xt[i];
    yf[j] := yt[i];
    zf[j] := zt[i]; // komponen vertikal 3D state space
    i := i + round(isf/fse);
  end;
  bts := j; //jumlah data ecg
end;

procedure TForm1.Run_appClick(Sender: TObject);
begin
  if Run_app.Caption = 'RUN' then
  begin
    Run_app.Caption:='STOP';
    Chart1LineSeries1.Clear;
    Chart2LineSeries1.Clear;
    Chart3LineSeries1.Clear;
    Chart3LineSeries2.Clear;
    Chart4LineSeries1.Clear;
    Chart4LineSeries2.Clear;
    Chart5LineSeries1.Clear;

    ti[1]:= -60;    ti[2]:= -15;  ti[3]:= 0;    ti[4]:= 15;     ti[5]:= 90;
    ai[1]:= 1.2;    ai[2]:= -5;   ai[3]:= 30;   ai[4]:= -7.5;   ai[5]:= 0.75;
    bi[1]:= 0.25;   bi[2]:= 0.1;  bi[3]:= 0.1;  bi[4]:= 0.1;    bi[5]:= 0.4;

    if radiobutton1.checked then
    begin
      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton2.checked then
    begin
      ai[1]:=-0.3;
      ai[2]:=0;
      ai[3]:=10;
      ai[4]:=-20;              ti[4]:=30;
      ai[5]:=0.3;              ti[5]:=105;
      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton3.Checked then
    begin
      ai[1]:=-0.2;
      ai[2]:=0;
      ai[3]:=20;
      ai[4]:=-20;               ti[4]:=30;
      ai[5]:=0.3;               ti[5]:=120;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton4.checked then
    begin
      ai[1]:=0;
      ai[2]:=0;
      ai[3]:=20;
      ai[4]:=-30;             ti[4]:=30;
      ai[5]:=2;   bi[5]:=0.3; ti[5]:=120;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton5.checked then
    begin
      ai[1]:=0;
      ai[2]:=-3;
      ai[3]:=40;
      ai[4]:=-20;           ti[4]:=30;
      ai[5]:=1;             ti[5]:=120;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton6.checked then
    begin
      ai[1]:=0.1;
      ai[2]:=-1;
      ai[3]:=40;
      ai[4]:=-5;
      ai[5]:=0.5;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton7.checked then
    begin
      ai[1]:=0.3;
      ai[2]:=-3;
      ai[3]:=30;
      ai[4]:=-5;
      ai[5]:=0.3;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton8.checked then
    begin
      ai[1]:=0.3;
      ai[2]:=-5;
      ai[3]:=30;
      ai[4]:=-5;
      ai[5]:=0.3;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton9.checked then
    begin
      ai[1]:=0;
      ai[2]:=-1;
      ai[3]:=10;
      ai[4]:=-5;
      ai[5]:=0.3;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton10.Checked then
    begin
      ai[1]:=0;
      ai[2]:=1;
      ai[3]:=-5;
      ai[4]:=0;
      ai[5]:=0.01; bi[5]:=0.6;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton11.checked then
    begin
      ai[1]:=-0.5;
      ai[2]:=1;
      ai[3]:=-30;
      ai[4]:=3;
      ai[5]:=-0.5;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton12.checked then
    begin
      ai[1]:=0.1;
      ai[2]:=1;
      ai[3]:=20;
      ai[4]:=0;
      ai[5]:=0.1;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end

    else if radiobutton13.checked then
    begin
      ai[1]:=0.3;
      ai[2]:=-3;
      ai[3]:=10;
      ai[4]:=-5;
      ai[5]:=0.2; bi[5]:=0.6;

      edit11.Text:= floattostr(ti[1]);   Edit14.Text:= floattostr(ti[2]);  Edit17.Text:= floattostr(ti[3]);  Edit20.Text:= floattostr(ti[4]);   Edit23.Text := floattostr(ti[5]);
      edit12.Text:= floattostr(ai[1]);   Edit15.Text:= floattostr(ai[2]);  Edit18.Text:= floattostr(ai[3]);  Edit21.Text:= floattostr(ai[4]);   Edit24.Text := floattostr(ai[5]);
      edit13.Text:= floattostr(bi[1]);   Edit16.Text:= floattostr(bi[2]);  Edit19.Text:= floattostr(bi[3]);  Edit22.Text:= floattostr(bi[4]);   Edit25.Text := floattostr(bi[5]);
    end;

    for i:=1 to 5 do
        ti[i] := ti[i]*pi/180;

    p_input;
    processing;
    r_kuttaorde4;
    down_samp;

    //agar range sinyal -0.4 - 1.2mV
    zma := zf[1];
    zmi := zf[1];
    for i:=2 to bts do
    begin
      if (zf[i] > zma) then
         zma := zf[i];
      if (zf[i] < zmi) then
         zmi := zf[i];
    end;

    zr := zma - zmi;
    k := bts div 10;
    for j:=1 to k do
    begin
      zf[i] := (zf[i] - zmi)*1.6/zr-0.4;
      zf[i] := zf[i] + randg(mean,std);
    end;

    i:=1;
    repeat
      delay(1);
      Chart5LineSeries1.AddXY(i,zf[i]);
      if i <= k-1 then
        inc(i);
    until(Run_app.Caption = 'RUN') ;
  end
  else if Run_app.Caption = 'STOP' then
  begin
    Run_app.Caption:='RUN';
    Chart1LineSeries1.Clear;
    Chart1LineSeries2.Clear;
    Chart2LineSeries1.Clear;
    Chart3LineSeries1.Clear;
    Chart3LineSeries2.Clear;
    Chart4LineSeries1.Clear;
    Chart4LineSeries2.Clear;
    //Chart5LineSeries1.Clear;
  end;
end;

procedure TForm1.delay(lama: integer);
var
  ulang: integer;
begin
 ulang := GetTickCount64;
 repeat
   Application.ProcessMessages;
 until ((GetTickCount64-ulang)>=lama);
end;

procedure TForm1.Cls_appClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.

