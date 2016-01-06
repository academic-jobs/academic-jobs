package Controller;

import java.util.Date;
import java.util.List;

import Model.Jobs;
import Model.Subject;
import Model.University;

import com.jfinal.core.Controller;

public class detailController extends Controller{
     public void index()
     {
    	
    	 
     }
     public void showdetails()
     {
    	 String title;
    	 String uni_name;
    	 Date placedtime;
    	 Date closetime;
    	 String subject;
    	 String explanation;
    	 String job_type;
    	 String location;
    	 String salary;
    	 String job_hours;
    	 String links;
    	 
    	 int id=getParaToInt(0);
    	 System.out.println(id);
    	 Jobs job=Jobs.dao.findById(id);
    	 System.out.println(job);
    	 
    	 
    	 title=job.getStr("title");
    	 System.out.println("1");
    	 System.out.println(title);
    	 
    	 uni_name=getuni_name(job.getLong("uni_id"));
    	 System.out.println("2");
    	 System.out.println(uni_name);
    	 
    	 placedtime=job.getDate("placed_on");
    	 System.out.println("3");
    	 System.out.println(placedtime);
    	 
    	 closetime=job.getDate("closes");
    	 System.out.println("4");
    	 System.out.println(closetime);
    	 
    	 subject=getsub(job.getLong("main_sub_id"));
    	 System.out.println("5");
    	 System.out.println(subject);
 
    	 explanation=job.getStr("text");
    	 System.out.println("6");
    	 System.out.println(explanation);
    	 
    	 job_type=job.getStr("job_type");
    	 System.out.println("7");
    	 System.out.println(job_type);
    	 
    	 location=job.getStr("location");
    	 System.out.println("8");
    	 System.out.println(location);
    	 
    	 salary=job.getStr("salary");
    	 System.out.println("9");
    	 System.out.println(salary);
    	 
    	 job_hours=job.getStr("job_hours");
    	 System.out.println("10");
    	 System.out.println(job_hours);
    	 
    	 links=job.getStr("url");
    	 System.out.println("11");
    	 System.out.println(links);
    	 
    	 setAttr("title",title);
    	 setAttr("uni_name",uni_name);
    	 setAttr("placedtime",placedtime);
    	 setAttr("closetime",closetime);
    	 setAttr("subject",subject);
    	 setAttr("explanation",explanation);
    	 setAttr("job_type",job_type);
    	 setAttr("location",location);
    	 setAttr("salary",salary);
    	 setAttr("job_hours",job_hours);
    	 setAttr("links",links);
    	 
    	 renderFreeMarker("/details/details.html");
    	 
     }
     
     private String getuni_name(long a)
     {
    	 int uni_id=(int)a;
    	 String uni_name;
    	 uni_name=University.dao.findById(uni_id).getStr("uni_name");
    	 return uni_name;
     }
     private String getsub(long a)
     {
    	 int sub_id=(int)a;
    	 String sub;
    	 sub=Subject.dao.findById(sub_id).getStr("main_sub");
    	 return sub;
     }
}
