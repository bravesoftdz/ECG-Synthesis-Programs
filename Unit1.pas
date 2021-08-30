unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls, Math;

type
  myArray1 = array [1..1000] of extended;

  TMainForm = class(TForm)
    btnProcess: TButton;
    btnClose: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Chart1: TChart;
    Chart2: TChart;
    Chart3: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series3: TLineSeries;
    Series4: TLineSeries;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    Edit22: TEdit;
    Edit23: TEdit;
    Edit24: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Edit25: TEdit;
    Label18: TLabel;
    function myidft(x,y: myArray1):myArray1;
    function ang_freq(in1 :extended):extended;
    function modulus(in1, in2: extended):extended;
    procedure input;
    procedure process;
    procedure rk4 (in1, in2 :extended);
    procedure tdss (in1 :extended; in2 :myArray1);
    procedure btnCloseClick(Sender: TObject);
    procedure btnProcessClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  hasilidft, hasil, x, rr, ti, ai, bi, temp, xt, yt, zt :myArray1;
  fhigh :extended;
  omega_l, omega_h, rad_l, rad_h, sig1, sig2, dt :extended;
  jh, sf, nt  :integer;
  MainForm: TMainForm;

implementation

{$R *.dfm}
function TMainForm.myidft(x: myArray1; y: myArray1):myArray1;
var
  j,k : integer;
  idft :myArray1;
begin
  for j:=1 to jh do
  begin
    idft[j] := 0;
    for k:=1 to jh do
    begin
      idft[j] := idft[j] + (x[k]*cos(2*pi*j*k/jh)) + (y[k]*sin(2*pi*j*k/jh));
    end;
    hasilidft[j] := idft[j]/jh;
  end;
  myidft := hasilidft;
end;

procedure TMainForm.input;
var
  i, isf, hrm, hrmsd :integer;
  flow, flowsd, fhighsd, lfhfrat, hrfact1, hrfact2 :extended;
begin
  jh      := strtoint(Edit16.Text);   // jumlah heartbeat
  sf      := strtoint(Edit17.Text);   // sampling frequency
  isf     := strtoint(Edit18.Text);   // Internal Sampling Frequency
  hrm     := strtoint(Edit19.Text);    // heart rate mean
  hrmsd   := strtoint(Edit20.Text);     // heart rate standart deviation
  flow    := strtofloat(Edit21.Text);   // Frequency low
  flowsd  := strtofloat(Edit22.Text);;  // Frequency low standart deviation
  fhigh   := strtofloat(Edit23.Text);;  // Frequency high
  fhighsd := strtofloat(Edit24.Text);;  // Frequency high standart deviation
  lfhfrat := strtofloat(Edit25.Text);;   // LF/HF Ratio

  //To convert into radian
  omega_l := 2*pi*flow;
  omega_h := 2*pi*fhigh;
  rad_l   := 2*pi*flowsd;
  rad_h   := 2*pi*fhighsd;

  sig1    := lfhfrat;
  sig2    := 1;

  hrfact1 := sqrt(hrm/60);
  hrfact2 := sqrt(hrfact1);
  dt := 1/sf;

  for i:=1 to 5 do
  begin
    ti[i] := ti[i]*pi/180;
  end;

  for i:=1 to 5 do
  begin
    bi[i] := bi[i]*hrfact1;
  end;

  ti[1] := ti[1]*hrfact2;
  ti[2] := ti[2]*hrfact1;
  ti[3] := ti[3]*1.0;
  ti[4] := ti[4]*hrfact1;
  ti[5] := ti[5]*hrfact2;
end;

procedure TMainForm.process;
var
  i : integer;
  wktu :extended;
  omega, rsa, mayer, rsa_mayer :myArray1;
  real_value, imag_value :myArray1;
begin
  //To find RSA Mayer
  for i:=1 to jh do
  begin
    omega[i] := 2*pi*dt*(i-1);
  end;

  //RSA Mayer signal
  for i:=1 to jh do
  begin
    mayer[i] := sig1*exp(-0.5*power((omega[i] - omega_l)/rad_l,2))/sqrt(2*pi*power(rad_l,2)); //gaussian mayer
    rsa[i]   := sig2*exp(-0.5*power((omega[i] - omega_h)/rad_h,2))/sqrt(2*pi*power(rad_h,2));
    rsa_mayer[i] := rsa[i] + mayer[i];
  end;

  for i := 1 to round(jh/2) do
  begin
    Series1.AddXY(omega[i]/(2*pi),rsa[i]);
    Series2.AddXY(omega[i]/(2*pi),mayer[i]);
  end;

  //To find Real and Imaginary value
  for i:=1 to jh do
  begin
    real_value[i] := rsa_mayer[i]*cos(2*pi*random);
    imag_value[i] := rsa_mayer[i]*sin(2*pi*random);
  end;

  //RR Tachogram
  myidft(real_value,imag_value);
  for i:=1 to jh do
  begin
    hasil[i] := hasilidft[i]+1;
    Series3.AddXY(i,hasil[i]);
  end;

  //Initialize first value for RK 4
  x[1] := 0.1;
  x[2] := 0.0;
  x[3] := 0.04;
  wktu := 1;

  //RK 4 Process
  for i:=1 to jh*3 do
  begin
    xt[i] := x[1];
    yt[i] := x[2];
    zt[i] := x[3];
    rk4(wktu,dt);
    wktu := wktu + dt;
    Series4.AddXY(i,zt[i]);
  end;
end;

procedure TMainForm.rk4(in1, in2 :extended);
var
  i : integer;
  k1, k2, k3, k4, y, ytt :myArray1;
begin
  for i:=1 to 3 do
  begin
    y[i] := x[i];
  end;

  tdss(in1,y); //3d state
  for i:= 1 to 3 do
  begin
    k1[i] := temp[i];
    ytt[i]:= y[i] + (0.5*in2*k1[i]);
  end;

  tdss(in1 + (in2*0.5),ytt); //3d state
  for i:=1 to 3 do
  begin
    k2[i] := temp[i];
    ytt[i]:= y[i] + (0.5*in2*k2[i]);
  end;

  tdss(in1 + (in2*0.5),ytt); //3d state
  for i:=1 to 3 do
  begin
    k3[i] := temp[i];
    ytt[i]:= y[i] + in2*k3[i];
  end;

  tdss(in1 + in2,ytt); //3d state
  for i:=1 to 3 do
  begin
    k4[i] := temp[i];
    x[i] := y[i] + in2/6*(k1[i] + 2*k2[i] + 2*k3[i] + k4[i]);
  end;
end;

procedure TMainForm.tdss(in1 :extended; in2 :myArray1);
var
  i :integer;
  a0, w0 :extended;
  teta, dteta1, dteta2, zbase :extended;
  xi, yi :myArray1;
begin
  w0 := ang_freq(in1);
  a0 := 1.0 - sqrt(sqr(in2[1] + in2[2]));
  for i:=1 to 5 do
  begin
    xi[i] := cos(ti[i]);
    yi[i] := sin(ti[i]);
  end;

  zbase := 0.005*sin(2*pi*fhigh*in1);

  if in2[1] = 0 then begin
    teta := 0;
  end
  else begin
    teta := arctan2(in2[2],in2[1]);
  end;

  temp[1] := a0*in2[1] - w0*in2[2];
  temp[2] := a0*in2[2] + w0*in2[1];
  temp[3] := 0;

  for i:=1 to 5 do
  begin
    dteta1 := modulus(teta - ti[i],2*pi);
    dteta2 := sqr(dteta1);
    if bi[i] = 0 then begin
      temp[3] := temp[3] + (-ai[i]*dteta1*exp(0));
    end
    else begin
      temp[3] := temp[3] + (-ai[i]*dteta1*exp(-0.5*dteta2/sqr(bi[i])));
    end;
  end;
  temp[3] := temp[3] + (-1.0*(in2[3] - zbase));
end;

function TMainForm.ang_freq(in1 :extended):extended;
var i :integer;
begin
  i:= 1 + floor(in1/dt);
  if hasil[i] = 0 then begin
    ang_freq := 2*pi;
  end
  else begin
    ang_freq := 2.0*pi/hasil[i];
  end;
end;

function TMainForm.modulus(in1, in2: extended):extended;
begin
  result := in1 - in2*trunc(in1/in2);
end;

procedure TMainForm.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.btnProcessClick(Sender: TObject);
begin
  Series1.Clear; Series2.Clear; Series3.Clear; Series4.Clear;
  ti[1] := strtofloat(Edit1.Text); ai[1] := strtofloat(Edit6.Text);  bi[1] := strtofloat(Edit11.Text);
  ti[2] := strtofloat(Edit2.Text); ai[2] := strtofloat(Edit7.Text);  bi[2] := strtofloat(Edit12.Text);
  ti[3] := strtofloat(Edit3.Text); ai[3] := strtofloat(Edit8.Text);  bi[3] := strtofloat(Edit13.Text);
  ti[4] := strtofloat(Edit4.Text); ai[4] := strtofloat(Edit9.Text);  bi[4] := strtofloat(Edit14.Text);
  ti[5] := strtofloat(Edit5.Text); ai[5] := strtofloat(Edit10.Text); bi[5] := strtofloat(Edit15.Text);
  input;
  process;
end;

end.
