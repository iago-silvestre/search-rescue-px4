/* Initial beliefs and rules */
water_y_offset(2.5).
search_area(13).
flight_altitude(3).
setpoint_goal(0,0,0).

/* Initial goals */
!setRTLAtlitude(5.0).
!setMaxSpeed(6).
!planPath.

+!setMaxSpeed(S)
	<- 	.set_fcu_param("MPC_XY_VEL_MAX", [0, S]).

+!setRTLAtlitude(A)
	<- 	.set_fcu_param("RTL_RETURN_ALT", [0, A]).


+!planPath: local_pos([0.0,0.0,'map'],[[X1, Y1, Z1], [X2, Y2, Z2, W2]])
   <- ?search_area(A);?water_y_offset(Y_OFFSET);
         .plan_path([1,[0,0],""],[[0,0],""],[[[0,[0,0],""],[[[X1, Y1, Z1],[X2, Y2, Z2, W2],[X1-A,Y1+Y_OFFSET,0.0],[X1-A,Y1+A+Y_OFFSET, 0.0]]]],[[0,[0,0],""],[[X1+A, Y1+A+Y_OFFSET, 0.0],[X1+A, Y1+Y_OFFSET, 0.0]]]]).

+!planPath <- !planPath.

+plan_path_result(PLIST)
   <- .camera_switch(true);
         !!publishSetPoint;
         .wait(2000);
         !!contactRescuers;
         !defineGoal(PLIST).

/* Define setpoint goal*/
+!defineGoal([H|T])
   <- H = [X, Y, _];
          ?flight_altitude(Z);
          -+setpoint_goal(X, Y, Z);
          .wait(local_pos([0.0,0.0,'map'],[[X2, Y2, Z2], [_, _, _, _]]) & math.abs(X2 - (X)) <= 0.7 & math.abs(Y2 - (Y)) <= 0.7 & math.abs(Z2 - (Z)) <= 0.7);
          !defineGoal(T).

+!defineGoal([])
   <- .drop_intention(publishSetPoint).

+!publishSetPoint: state("OFFBOARD", _, true)
   <- ?setpoint_goal(X, Y, Z);
         .setpoint_local([0.0,0.0,'map'], [[X, Y, Z], [0.0, 0.0, 0.0, 1.0]]);
         .wait(200);
         !publishSetPoint.

+!publishSetPoint: not state("OFFBOARD", _, true)
   <- .arming(true);
         .set_mode("OFFBOARD");
         ?setpoint_goal(X, Y, Z);
         .setpoint_local([0.0,0.0,'map'],[[X, Y, Z], [0.0, 0.0, 0.0, 1.0]]);
         .wait(200);
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