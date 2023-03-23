import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../shared/components/components.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class Homelayout extends StatelessWidget
{
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  var titleController =TextEditingController();
  var timeController =TextEditingController();
  var dataController =TextEditingController();




  @override
  Widget build(BuildContext context)
  {


    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit , AppStates>(
        listener: (BuildContext context,AppStates state)
        {
          if(state is AppInserteDatabaseState)
          {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context , AppStates state){
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key:scaffoldkey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if(cubit.isBottomSheetShown) {
                  if(formkey.currentState!.validate()) {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        data: dataController.text
                    );
                  }
                }else
                {
                  scaffoldkey.currentState?.showBottomSheet
                    ((context) => Container(
                    color: Colors.grey[100],
                    padding: EdgeInsets.all(20.0,),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          defaultFormFild(
                            controller: titleController,
                            type: TextInputType.text,
                            validate: (String value)
                            {
                              if(value.isEmpty)
                              {
                                return 'title must not be empty';
                              }
                              return null;
                            },
                            label: 'Task Title',
                            prefix: Icons.title,
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          defaultFormFild(
                            controller: timeController,
                            type: TextInputType.datetime,
                            onTap: (){
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((value)
                              {
                                timeController.text = value!.format(context).toString();
                                print(value.format(context));
                              });
                            },
                            validate: (String value)
                            {
                              if(value.isEmpty)
                              {
                                return 'time must not be empty';
                              }
                              return null;
                            },
                            label: 'Task Time',
                            prefix: Icons.watch_later_outlined,
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          defaultFormFild(
                            controller: dataController,
                            type: TextInputType.datetime,
                            onTap: ()
                            {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.parse('2022-09-03'),
                              ).then((value)
                              {
                                dataController.text = DateFormat.yMMMd().format(value!);
                              });
                            },
                            validate: (String value)
                            {
                              if(value.isEmpty)
                              {
                                return 'data must not be empty';
                              }
                              return null;
                            },
                            label: 'Task Data',
                            prefix: Icons.calendar_today,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ).closed.then((value) {
                    cubit.changeBottomSHeetState(
                      isShow: false,
                      icon: Icons.edit,);
                  });
                  cubit.changeBottomSHeetState(
                    isShow: true,
                    icon: Icons.add,);
                }

              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex:  cubit.currentIndex,
              onTap: (index)
              {
                cubit.changeIndex(index);

              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archaive',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Future<String> getName()  async
  // {
  // return 'Ahmed Ali';
  // }

}


