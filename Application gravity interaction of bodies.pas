uses Timers;
uses System, System.Windows.Forms;

const n = 100;
const deltaT = 60;
const G = 667.43;

var
  f, massForm: System.Windows.Forms.Form;
  massEdit: System.Windows.Forms.TextBox;
  Graf1: System.Drawing.Graphics;
  startStopBtn, wipeBtn, enterMassBtn, cancelMassBtn: System.Windows.Forms.Button;
  labForMassForm: System.Windows.Forms.Label;
  
  x: array[1..n] of real;
  y: array[1..n] of real;
  xView: array[1..n] of real;
  yView: array[1..n] of real;
  m: array[1..n] of real;
  ax: array[1..n] of real;
  ay: array[1..n] of real;
  vx: array[1..n] of real;
  vy: array[1..n] of real;
  brushes: array[1..n] of System.Drawing.Brush;
  count: integer;
  scale, xMouse, yMouse: longint;
  isStarted: boolean; //по умолчанию false
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
procedure accelerationCalculation(r, G: real; p, q: integer; var x1, y1, m1, x2, y2, m2, a1x, a1y, a2x, a2y: real);
begin
  a1x := a1x + G*m2*(x2-x1)/(r*sqrt(r));
  a1y := a1y + G*m2*(y2-y1)/(r*sqrt(r));
  a2x := a2x + G*m1*(x1-x2)/(r*sqrt(r));
  a2y := a2y + G*m1*(y1-y2)/(r*sqrt(r));
end;

procedure newSpeedCalculation(var vx, vy: real; ax, ay, deltaT: real);
begin
  vx := vx + ax*deltaT;
  vy := vy + ay*deltaT;
end;

procedure TimerProc;
var
  i, j: integer;
  r: real;
begin
  for i := 1 to count do begin
    for j := (i+1) to count do begin
      r := sqr(x[i]-x[j]) + sqr(y[i]-y[j]);
      accelerationCalculation(r, G, i, j, x[i], y[i], m[i], x[j], y[j], m[j], ax[i], ay[i], ax[j], ay[j]); 
    end;
    newSpeedCalculation(vx[i], vy[i], ax[i], ay[i], deltaT);
    x[i] := x[i] + vx[i]*deltaT + ax[i]*sqr(deltaT)/2;
    y[i] := y[i] + vy[i]*deltaT + ay[i]*sqr(deltaT)/2;
    xView[i] := trunc(x[i]/scale - 5);
    yView[i] := trunc(y[i]/scale - 5);
    Graf1.FillEllipse(brushes[i],xView[i],yView[i],10,10);
  end;
end;

procedure enterMassButtonClick(sender: object; e: EventArgs);
var
  err: integer;
begin
  count += 1;
  val(massEdit.text,m[count],err);
  x[count] := xMouse*scale;
  y[count] := yMouse*scale;
  m[count] := m[count]/10;
  
  case count mod 10 of
    1: brushes[count] := System.Drawing.Brushes.Blue;
    2: brushes[count] := System.Drawing.Brushes.Gold;
    3: brushes[count] := System.Drawing.Brushes.Green;
    4: brushes[count] := System.Drawing.Brushes.Orange;
    5: brushes[count] := System.Drawing.Brushes.Tan;
    6: brushes[count] := System.Drawing.Brushes.Crimson;
    7: brushes[count] := System.Drawing.Brushes.Cyan;
    8: brushes[count] := System.Drawing.Brushes.Chocolate;
    9: brushes[count] := System.Drawing.Brushes.LightSeaGreen;
    0: brushes[count] := System.Drawing.Brushes.Firebrick;
  end;
  
  Graf1.FillEllipse(brushes[count],xMouse-5,yMouse-5,10,10);
  massForm.Close();
end;

procedure cancelMassButtonClick(sender: object; e: EventArgs);
begin
  massForm.Close();
end;

procedure StartStopButtonClick(sender: object; e: EventArgs);
var
  t := new Timer(100,TimerProc);
begin
  if isStarted then begin
    t.Stop;
    startStopBtn.Text := 'Start';
    wipeBtn.BackColor := System.Drawing.Color.DarkKhaki;
  end
  else begin
    t.Start;
    startStopBtn.Text := 'Stop';
    wipeBtn.BackColor := System.Drawing.Color.Khaki;
  end;
  isStarted := not(isStarted);
end;

procedure wipeButtonClick(sender: object; e: EventArgs);
var
  i: longint;
begin
  if not(isStarted) then begin
    for i := 1 to count do begin
      m[count] := 0;
      x[count] := 0;
      y[count] := 0;
      brushes[count] := System.Drawing.Brushes.White;
    end;
    
    count := 0;
  end;
end;

procedure onMouseDown(sender:Object; e:System.Windows.Forms.MouseEventArgs); //создание мат. точки и задание её массы (вывод диалогового окна)
var
  sX, sY: string;
begin
  if not(isStarted) then begin
    xMouse := e.x;
    yMouse := e.y;
    
    sX := Format('{0:N0}', xMouse*scale);
    sY := Format('{0:N0}', yMouse*scale);
    
    massForm := new Form;
    massForm.Height := 200;
    massForm.Width := 400;
    massForm.Text := 'Ввод массы объекта';
    
    labForMassForm := System.Windows.Forms.Label.Create;
    labForMassForm.Height := 50;
    labForMassForm.Width := 215;
    labForMassForm.Left := 10;
    labForMassForm.Top := 10;
    labForMassForm.Text := 'Введите массу в млрд. тонн. Координаты тела: ' + sX + ' - по x, ' + sY + ' - по y.';
    
    massEdit := new TextBox;
    massEdit.Height := 20;
    massEdit.Width := 200;
    massEdit.Left := 10;
    massEdit.Top := 70;
    massEdit.AcceptsTab := true;
    
    cancelMassBtn := new Button;
    cancelMassBtn.Height := 20;
    cancelMassBtn.Width := 100;
    cancelMassBtn.Left := 280;
    cancelMassBtn.Top := 70;
    cancelMassBtn.Text := 'Cancel';
    cancelMassBtn.Click += cancelMassButtonClick;
    massForm.AcceptButton := cancelMassBtn;
    
    enterMassBtn := new Button;
    enterMassBtn.Height := 20;
    enterMassBtn.Width := 50;
    enterMassBtn.Left := 220;
    enterMassBtn.Top := 70;
    enterMassBtn.Text := 'OK';
    enterMassBtn.Click += enterMassButtonClick;
    massForm.AcceptButton := enterMassBtn;
    
    massForm.Controls.Add(labForMassForm);
    massForm.Controls.Add(enterMassBtn);
    massForm.Controls.Add(cancelMassBtn);
    massForm.Controls.Add(massEdit);
    
    massForm.ShowDialog();
    
    massForm.ActiveControl := massEdit;
  end;
end;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
begin
  scale := 1000000;
  {count := 2;
  x[1] := 200000000;
  y[1] := 300000000;
  m[1] := 597360000000;
  brushes[1] := System.Drawing.Brushes.Green;
  x[2] := 586400000;
  y[2] := 300000000;
  m[2] := 7350000000;
  vy[2] := 1023;
  brushes[2] := System.Drawing.Brushes.Gray;}
  
  f := new Form;
  f.Height := 600;
  f.Width := 800;
  f.Text := 'Gravity Interaction Of Bodies';
  f.StartPosition := FormStartPosition.CenterScreen;
  f.MaximizeBox := false;
  f.BackColor := System.Drawing.Color.White;
  f.MouseDown += onMouseDown;
  
  Graf1 := System.Drawing.Graphics.FromHwnd (f.Handle);
  
  //кнопки
  wipeBtn := new Button;
  wipeBtn.Height := 50;
  wipeBtn.Width := 100;
  wipeBtn.Left := 140;
  wipeBtn.Top := 20;
  wipeBtn.Text := 'Clear';
  wipeBtn.BackColor := System.Drawing.Color.DarkKhaki;
  wipeBtn.Click += wipeButtonClick;
  f.AcceptButton := wipeBtn;
  
  startStopBtn := new Button;
  startStopBtn.Height := 50;
  startStopBtn.Width := 100;
  startStopBtn.Left := 20;
  startStopBtn.Top := 20;
  startStopBtn.Text := 'Start';
  startStopBtn.BackColor := System.Drawing.Color.DarkKhaki;
  startStopBtn.Click += StartStopButtonClick;
  f.AcceptButton := startStopBtn;
  
  
  f.Controls.Add(wipeBtn);
  f.Controls.Add(startStopBtn);
  Application.Run(f);
end.