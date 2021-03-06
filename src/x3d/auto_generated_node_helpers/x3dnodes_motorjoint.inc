{ -*- buffer-read-only: t -*-

  Copyright 2015-2018 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Automatically generated node properties.

  Do not edit this file manually!
  To add new properties:
  - add them to the text files in tools/internal/x3d-nodes-to-pascal/nodes-specification/ ,
  - and regenerate include files by running x3d-nodes-to-pascal .

  The documentation for properties should go to x3dnodes_documentation.txt . }

{$ifdef read_interface}

  strict private
    function GetAxis1Angle: Single;
    procedure SetAxis1Angle(const Value: Single);
    function GetAxis1Torque: Single;
    procedure SetAxis1Torque(const Value: Single);
    function GetAxis2Angle: Single;
    procedure SetAxis2Angle(const Value: Single);
    function GetAxis2Torque: Single;
    procedure SetAxis2Torque(const Value: Single);
    function GetAxis3Angle: Single;
    procedure SetAxis3Angle(const Value: Single);
    function GetAxis3Torque: Single;
    procedure SetAxis3Torque(const Value: Single);
    function GetEnabledAxes: Integer;
    procedure SetEnabledAxes(const Value: Integer);
    function GetMotor1Axis: TVector3;
    procedure SetMotor1Axis(const Value: TVector3);
    function GetMotor2Axis: TVector3;
    procedure SetMotor2Axis(const Value: TVector3);
    function GetMotor3Axis: TVector3;
    procedure SetMotor3Axis(const Value: TVector3);
    function GetStop1Bounce: Single;
    procedure SetStop1Bounce(const Value: Single);
    function GetStop1ErrorCorrection: Single;
    procedure SetStop1ErrorCorrection(const Value: Single);
    function GetStop2Bounce: Single;
    procedure SetStop2Bounce(const Value: Single);
    function GetStop2ErrorCorrection: Single;
    procedure SetStop2ErrorCorrection(const Value: Single);
    function GetStop3Bounce: Single;
    procedure SetStop3Bounce(const Value: Single);
    function GetStop3ErrorCorrection: Single;
    procedure SetStop3ErrorCorrection(const Value: Single);
    function GetAutoCalc: boolean;
    procedure SetAutoCalc(const Value: boolean);
  public
    { X3D field "axis1Angle". } { }
    property Axis1Angle: Single read GetAxis1Angle write SetAxis1Angle;
    { X3D field "axis1Torque". } { }
    property Axis1Torque: Single read GetAxis1Torque write SetAxis1Torque;
    { X3D field "axis2Angle". } { }
    property Axis2Angle: Single read GetAxis2Angle write SetAxis2Angle;
    { X3D field "axis2Torque". } { }
    property Axis2Torque: Single read GetAxis2Torque write SetAxis2Torque;
    { X3D field "axis3Angle". } { }
    property Axis3Angle: Single read GetAxis3Angle write SetAxis3Angle;
    { X3D field "axis3Torque". } { }
    property Axis3Torque: Single read GetAxis3Torque write SetAxis3Torque;
    { X3D field "enabledAxes". } { }
    property EnabledAxes: Integer read GetEnabledAxes write SetEnabledAxes;
    { X3D field "motor1Axis". } { }
    property Motor1Axis: TVector3 read GetMotor1Axis write SetMotor1Axis;
    { X3D field "motor2Axis". } { }
    property Motor2Axis: TVector3 read GetMotor2Axis write SetMotor2Axis;
    { X3D field "motor3Axis". } { }
    property Motor3Axis: TVector3 read GetMotor3Axis write SetMotor3Axis;
    { X3D field "stop1Bounce". } { }
    property Stop1Bounce: Single read GetStop1Bounce write SetStop1Bounce;
    { X3D field "stop1ErrorCorrection". } { }
    property Stop1ErrorCorrection: Single read GetStop1ErrorCorrection write SetStop1ErrorCorrection;
    { X3D field "stop2Bounce". } { }
    property Stop2Bounce: Single read GetStop2Bounce write SetStop2Bounce;
    { X3D field "stop2ErrorCorrection". } { }
    property Stop2ErrorCorrection: Single read GetStop2ErrorCorrection write SetStop2ErrorCorrection;
    { X3D field "stop3Bounce". } { }
    property Stop3Bounce: Single read GetStop3Bounce write SetStop3Bounce;
    { X3D field "stop3ErrorCorrection". } { }
    property Stop3ErrorCorrection: Single read GetStop3ErrorCorrection write SetStop3ErrorCorrection;
    { X3D field "autoCalc". } { }
    property AutoCalc: boolean read GetAutoCalc write SetAutoCalc;

{$endif read_interface}

{$ifdef read_implementation}

{ TMotorJointNode ----------------------------------------------- }

function TMotorJointNode.GetAxis1Angle: Single;
begin
  Result := FdAxis1Angle.Value;
end;

procedure TMotorJointNode.SetAxis1Angle(const Value: Single);
begin
  FdAxis1Angle.Send(Value);
end;

function TMotorJointNode.GetAxis1Torque: Single;
begin
  Result := FdAxis1Torque.Value;
end;

procedure TMotorJointNode.SetAxis1Torque(const Value: Single);
begin
  FdAxis1Torque.Send(Value);
end;

function TMotorJointNode.GetAxis2Angle: Single;
begin
  Result := FdAxis2Angle.Value;
end;

procedure TMotorJointNode.SetAxis2Angle(const Value: Single);
begin
  FdAxis2Angle.Send(Value);
end;

function TMotorJointNode.GetAxis2Torque: Single;
begin
  Result := FdAxis2Torque.Value;
end;

procedure TMotorJointNode.SetAxis2Torque(const Value: Single);
begin
  FdAxis2Torque.Send(Value);
end;

function TMotorJointNode.GetAxis3Angle: Single;
begin
  Result := FdAxis3Angle.Value;
end;

procedure TMotorJointNode.SetAxis3Angle(const Value: Single);
begin
  FdAxis3Angle.Send(Value);
end;

function TMotorJointNode.GetAxis3Torque: Single;
begin
  Result := FdAxis3Torque.Value;
end;

procedure TMotorJointNode.SetAxis3Torque(const Value: Single);
begin
  FdAxis3Torque.Send(Value);
end;

function TMotorJointNode.GetEnabledAxes: Integer;
begin
  Result := FdEnabledAxes.Value;
end;

procedure TMotorJointNode.SetEnabledAxes(const Value: Integer);
begin
  FdEnabledAxes.Send(Value);
end;

function TMotorJointNode.GetMotor1Axis: TVector3;
begin
  Result := FdMotor1Axis.Value;
end;

procedure TMotorJointNode.SetMotor1Axis(const Value: TVector3);
begin
  FdMotor1Axis.Send(Value);
end;

function TMotorJointNode.GetMotor2Axis: TVector3;
begin
  Result := FdMotor2Axis.Value;
end;

procedure TMotorJointNode.SetMotor2Axis(const Value: TVector3);
begin
  FdMotor2Axis.Send(Value);
end;

function TMotorJointNode.GetMotor3Axis: TVector3;
begin
  Result := FdMotor3Axis.Value;
end;

procedure TMotorJointNode.SetMotor3Axis(const Value: TVector3);
begin
  FdMotor3Axis.Send(Value);
end;

function TMotorJointNode.GetStop1Bounce: Single;
begin
  Result := FdStop1Bounce.Value;
end;

procedure TMotorJointNode.SetStop1Bounce(const Value: Single);
begin
  FdStop1Bounce.Send(Value);
end;

function TMotorJointNode.GetStop1ErrorCorrection: Single;
begin
  Result := FdStop1ErrorCorrection.Value;
end;

procedure TMotorJointNode.SetStop1ErrorCorrection(const Value: Single);
begin
  FdStop1ErrorCorrection.Send(Value);
end;

function TMotorJointNode.GetStop2Bounce: Single;
begin
  Result := FdStop2Bounce.Value;
end;

procedure TMotorJointNode.SetStop2Bounce(const Value: Single);
begin
  FdStop2Bounce.Send(Value);
end;

function TMotorJointNode.GetStop2ErrorCorrection: Single;
begin
  Result := FdStop2ErrorCorrection.Value;
end;

procedure TMotorJointNode.SetStop2ErrorCorrection(const Value: Single);
begin
  FdStop2ErrorCorrection.Send(Value);
end;

function TMotorJointNode.GetStop3Bounce: Single;
begin
  Result := FdStop3Bounce.Value;
end;

procedure TMotorJointNode.SetStop3Bounce(const Value: Single);
begin
  FdStop3Bounce.Send(Value);
end;

function TMotorJointNode.GetStop3ErrorCorrection: Single;
begin
  Result := FdStop3ErrorCorrection.Value;
end;

procedure TMotorJointNode.SetStop3ErrorCorrection(const Value: Single);
begin
  FdStop3ErrorCorrection.Send(Value);
end;

function TMotorJointNode.GetAutoCalc: boolean;
begin
  Result := FdAutoCalc.Value;
end;

procedure TMotorJointNode.SetAutoCalc(const Value: boolean);
begin
  FdAutoCalc.Send(Value);
end;

{$endif read_implementation}
