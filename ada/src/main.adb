with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   procedure DINING_PHILOSOPHERS (NO_OF_PHILOSOPHERS : Integer :=5;
                                  NO_OF_MEALS: Integer := 6;
                                  MEAL_LENGTH, THINK_TIME : Duration := 0.0) IS

      subtype PHIL_TYPE is Integer range 1..NO_OF_PHILOSOPHERS;

      task type CHOPSTICK is
         entry GET_CHOPSTIK;
         entry DROP_CHOPSTICK;
      end CHOPSTICK;

      TYPE STICK_POINTER is access CHOPSTICK;

      task type PHILOSOPHER IS

         entry GIVE_ID(ID : Integer);

         entry TELL_PHILOSOPHER_HOW_TO_USE_STICKS (FIRST_CHOPSTICK,
                                                  SECOND_CHOPSTICK :
                                                   STICK_POINTER);
      END PHILOSOPHER;

      TYPE PHIL_POINTER is access PHILOSOPHER;

      task  body CHOPSTICK IS
      begin
         loop
         select
            accept GET_CHOPSTIK;
         OR
            terminate;
         END select;
         accept DROP_CHOPSTICK;
      END LOOP;
   END CHOPSTICK;

      TASK BODY PHILOSOPHER IS
         Cor_id : Integer;
         FIRST_STICK,
         SECOND_STICK : STICK_POINTER;
      begin

         accept GIVE_ID(ID : Integer) do
            Cor_id := ID;
         end;

         accept TELL_PHILOSOPHER_HOW_TO_USE_STICKS (FIRST_CHOPSTICK, SECOND_CHOPSTICK : STICK_POINTER) do
            FIRST_STICK := FIRST_CHOPSTICK;
            SECOND_STICK := SECOND_CHOPSTICK;
         END TELL_PHILOSOPHER_HOW_TO_USE_STICKS;

         FOR I in 1..NO_OF_MEALS LOOP
            FIRST_STICK.GET_CHOPSTIK;
            SECOND_STICK.GET_CHOPSTIK;
            Put_Line("Eating " & Cor_id'Img);
            DELAY MEAL_LENGTH;
            SECOND_STICK.DROP_CHOPSTICK;
            FIRST_STICK.DROP_CHOPSTICK;
            Put_Line("-----------Thinking" & Cor_id'Img);
            delay THINK_TIME;

         END loop;
      END PHILOSOPHER;

   begin
      declare
         THIS_SP : STICK_POINTER := NEW CHOPSTICK;
         FIRST_SP : STICK_POINTER := THIS_SP;
         NEXT_SP : STICK_POINTER;
         P : PHIL_POINTER := NEW PHILOSOPHER;

      begin
         P.GIVE_ID(0);
      for I in 1..PHIL_TYPE'Last -1 loop
            NEXT_SP := NEW CHOPSTICK;
            P.TELL_PHILOSOPHER_HOW_TO_USE_STICKS(THIS_SP,NEXT_SP);
            THIS_SP := NEXT_SP;
            P := NEW PHILOSOPHER;
            P.GIVE_ID(I);
         END loop;
         P.TELL_PHILOSOPHER_HOW_TO_USE_STICKS(FIRST_SP,THIS_SP);
      end;
   end DINING_PHILOSOPHERS;


begin
   DINING_PHILOSOPHERS(5,5,0.3);
end Main;
