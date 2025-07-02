/* Initial beliefs and rules */
water_y_offset(2.5).
search_area(13).
flight_altitude(3).
setpoint_goal(0,0,0).
local_pos(X1,Y1,Z1,X2,Y2,Z2,W2) :- odom(header(seq(Seq),stamp(secs(Secs),nsecs(Nsecs)),frame_id("map")),child_frame_id(CFI),pose(pose(position(x(X1),y(Y1),z(Z1)),orientation(x(X2),y((Y2)),z((Z2)),w((W2)))),covariance(CV)),twist(twist(linear(x(LX),y(LY),z((LZ))),angular(x(AX),y((AY)),z((AZ)))),covariance(CV2))).
/* Initial goals */
!setRTLAtlitude(5.0).
!setMaxSpeed(6).
!planPath.

+!setMaxSpeed(S)
	<- 	.set_fcu_param("MPC_XY_VEL_MAX", [0, S]).

+!setRTLAtlitude(A)
	<- 	.set_fcu_param("RTL_RETURN_ALT", [0, A]).

+!planPath : local_pos(X1,Y1,Z1,X2,Y2,Z2,W2) & search_area(A) & water_y_offset(Y_OFFSET)
	<- 	.plan_path([1,[0,0],""],[[0,0],""],[[[0,[0,0],""],[[[0.0,0.0,0.0],[10.0,0.0,0.0],[7.0,4.0,0.0],[0.0,5.0,88.0]]]],[[0,[0,0],""],[[1.0,3.0,0.0],[0.0,0.0,0.0,1.0]]]]).

+plan_path_result(_, _, result(plan(_, points(PLIST)))) 
   <- .camera_switch(true);
      !!publishSetPoint;
      .wait(2000);
      !!contactRescuers;
      !defineGoal(PLIST).

+!planPath <- !planPath.
// Define setpoint goal
+!defineGoal([point(x(X),y(Y),z(Z)) | T])
   <- ?flight_altitude(ALT);
      -+setpoint_goal(X, Y, ALT);
      .wait(local_pos(X2,Y2,Z2,_,_,_,_) & math.abs(X2-X) <= 0.3 & math.abs(Y2-Y) <= 0.3 & math.abs(Z2-ALT) <= 0.3);
      !defineGoal(T).

+!defineGoal([type(_) | T]) 
   <- !defineGoal(T).

+!defineGoal([])
   <- .drop_intention(publishSetPoint).

+!publishSetPoint  : state(_, _, _, _, _, mode("OFFBOARD"), _)
   <- ?setpoint_goal(X, Y, Z);
      .setpoint_local([0.0,0.0,'map'], [[X, Y, Z], [0.0, 0.0, 0.0, 1.0]]);
      .wait(500);
      !publishSetPoint.

+!publishSetPoint : not state(_, _, _, _, _, mode("OFFBOARD"), _)
   <- .arming(true);
      ?setpoint_goal(X, Y, Z);
      .set_mode("OFFBOARD");
      .setpoint_local([0.0,0.0,'map'], [[X, Y, Z], [0.0, 0.0, 0.0, 1.0]]);
      .wait(500);
      !publishSetPoint.

+victim(ID, GX, GY)
   <- +victim_position(ID, GX, GY).

+victim_position(ID, GX, GY)
   <- .resume(contactRescuers).

+!contactRescuers: victim_position(_, _, _)
 	<- 	.findall([ID, GX, GY], victim_position(ID, GX, GY), VLIST);
            !informVictim(VLIST);
            !contactRescuers.

+!contactRescuers <- .suspend; !contactRescuers.

+!informVictim([H|T])
	<- H = [ID, GX, GY]
			.print("Victim ", H);
			.time(HH,MM,SS,MS);
			.broadcast(tell, victim_in_need(ID, GX, GY)[lu(HH,MM,SS,MS)]);
			-victim_position(ID, _, _);
			.wait(500);
			!informVictim(T).

+!informVictim([]).

+!mark_as_rescued(N, Lat, Long).