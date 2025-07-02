/* Initial beliefs and rules */
water_y_offset(2.5).
search_area(13).
flight_altitude(3).
setpoint_teste(10,10,5).
my_frame_id("map").
ground_truth(X1,Y1,Z1,X2,Y2,Z2,W2) :- my_frame_id(Frame_id) & odom(header(seq(Seq),stamp(secs(Secs),nsecs(Nsecs)),frame_id(Frame_id)),child_frame_id(CFI),pose(pose(position(x(X1),y(Y1),z(Z1)),orientation(x(X2),y((Y2)),z((Z2)),w((W2)))),covariance(CV)),twist(twist(linear(x(LX),y(LY),z((LZ))),angular(x(AX),y((AY)),z((AZ)))),covariance(CV2))).
//path_list(PLIST) :- path_result(_, _, result(plan(_, points(PLIST)))).
//+result(PLIST) : <- !startPath(PLIST).


//+result(PLIST) <- !startPath(PLIST).

/* Initial goals */
!start.


+!start
   <- .print("Started");
      .set_mode("AUTO.TAKEOFF");
      .wait(1000);
      .arming(true);
      .wait(1000);
      .set_mode("OFFBOARD");
      .wait(12000);
      !setRTLAtlitude(5.0);
      !setMaxSpeed(1);
      //.plan_path([1,[0,0],""],[[0,0],""],[[[0,[0,0],""],[[[0.0,0.0,0.0],[10.0,0.0,0.0],[7.0,4.0,0.0],[0.0,5.0,88.0]]]],[[0,[0,0],""],[[1.0,3.0,0.0],[0.0,0.0,0.0,1.0]]]]).
      !planPath.
      //!!publishSetPoint. 
      
      
        
+!setMaxSpeed(S)
	<- 	.set_fcu_param("MPC_XY_VEL_MAX", [0, S]);
         .print("set max speed to ", S).

+!setRTLAtlitude(A)
	<- 	.set_fcu_param("RTL_RETURN_ALT", [0, A]);
         .print("set altitude to ", A).

+!planPath
   : ground_truth(X1,Y1,Z1,X2,Y2,Z2,W2) & search_area(A) & water_y_offset(Y_OFFSET)
	<- 	.print("calling plan path for area ", A);
         .print("My position is X: ",X1,", Y: ",Y1,", Z: ",Z1,"|| And Orientation RX: ",X2,", RY: ",Y2,", RZ: ",Z2,",RW: ",W2);
			//.plan_path([1,[0,0],""],[[0,0],""],[[[0,[0,0],""],[[[0.0,0.0,0.0],[10.0,0.0,0.0],[7.0,4.0,0.0],[0.0,5.0,88.0]]]],[[0,[0,0],""],[[1.0,3.0,0.0],[0.0,0.0,0.0,1.0]]]]).
         //.plan_path([1,[0,0],""],[[0,0],""],[[X1-A, Y1+Y_OFFSET, 0],[X1-A, Y1+A+Y_OFFSET, 0],[X1+A, Y1+A+Y_OFFSET, 0],[X1+A, Y1+Y_OFFSET, 0]]).
         //.plan_path(X1,Y1,Z1,X2,Y2,Z2,W2,[[X1-A, Y1+Y_OFFSET, 0.0],[X1-A, Y1+A+Y_OFFSET, 0.0],[X1+A, Y1+A+Y_OFFSET, 0.0],[X1+A, Y1+Y_OFFSET, 0.0]]).
         //.plan_path([1,[0,0],""],[[0,0],""],[[0,[0,0],""],[[X1-A, Y1+Y_OFFSET, 0.0],[X1-A, Y1+A+Y_OFFSET, 0.0],[X1+A, Y1+A+Y_OFFSET, 0.0],[X1+A, Y1+Y_OFFSET, 0.0]]]).
         .plan_path([1,[0,0],""],[[0,0],""],[[[0,[0,0],""],[[[0.0,0.0,0.0],[10.0,0.0,0.0],[7.0,4.0,0.0],[0.0,5.0,88.0]]]],[[0,[0,0],""],[[1.0,3.0,0.0],[0.0,0.0,0.0,1.0]]]]).
         
         

+path_result(_, _, result(plan(_, points(PLIST)))) 
   <- .print("Received new planpath result: ",PLIST);
         !!publishSetPoint;
         .wait(2000);
         !!contactRescuers;
         !defineGoal(PLIST).

// Define setpoint goal
+!defineGoal([point(x(X),y(Y),z(Z)) | T])
   <- ?flight_altitude(ALT);
      -+setpoint_goal(X, Y, ALT);
      .wait(ground_truth(X2,Y2,Z2,_,_,_,_) & math.abs(X2-X) <= 0.3 & math.abs(Y2-Y) <= 0.3 & math.abs(Z2-ALT) <= 0.3);
      .print("reached waypoint");
      !defineGoal(T).

+!defineGoal([type(_) | T])  //% just skip over type annotations
   <- !defineGoal(T).

+!defineGoal([])
   <- .drop_intention(publishSetPoint);
      .print("Finished path").

+!publishSetPoint
   :   not setpoint_goal(X, Y, Z)
   <- .wait(200);
      !publishSetPoint.

+!publishSetPoint
   : state(_, _, _, _, _, mode("OFFBOARD"), _)
   <- ?setpoint_goal(X, Y, Z);
      .print("OFFBOARD Going to X: ",X,", Y: ",Y,", Z: ",Z);
      .setpoint_local([0.0,0.0,'map'], [[X, Y, Z], [0.0, 0.0, 0.0, 1.0]]);
      .wait(500);
      !publishSetPoint.

+!publishSetPoint
   : not state(_, _, _, _, _, mode("OFFBOARD"), _)
   <- ?setpoint_goal(X, Y, Z);
      .set_mode("OFFBOARD");
      .print("NOT OFFBOARD Going to X: ",X,", Y: ",Y,", Z: ",Z);
      .setpoint_local([0.0,0.0,'map'], [[X, Y, Z], [0.0, 0.0, 0.0, 1.0]]);
      .wait(500);
      !publishSetPoint.

/*+!publishSetPoint: not state("OFFBOARD", _, true)
   <- .arming(true);
         .set_mode("OFFBOARD");
         ?setpoint_goal(X, Y, Z);
         //.print("Going to X: ",X,", Y: ",Y,", Z: ",Z);
         .setpoint_local([0.0,0.0,'map'],[[X, Y, Z], [0.0, 0.0, 0.0, 1.0]]);
         .wait(200);
         !publishSetPoint.*/

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

+!planPath <- !planPath.
/* !pub_waypoints.
+!pub_waypoints : true
   <- .setpoint_local([0.0,0.0,'map'],[[10.0, 5.0, 8.0], [0.0, 0.0, 0.0, 1.0]]);
      //.wait(100);
      !pub_waypoints.

!planpath.
+!planpath : true
   <- .print("Plan Path test!");
   .plan_path([1,[0,0],""],[[0,0],""],[[[0,[0,0],""],[[[0.0,0.0,0.0],[10.0,0.0,0.0],[7.0,4.0,0.0],[0.0,5.0,88.0]]]],[[0,[0,0],""],[[1.0,3.0,0.0],[0.0,0.0,0.0,1.0]]]]).

!arm.
+!arm : true
   <- .arming(true). 


!mode.
+!mode : true
   <- .set_mode("OFFBOARD"). */