package Controller;

import java.util.List;

import Model.Jobs;
import Model.Subject;
import Model.University;

import com.jfinal.core.Controller;

public class indexController extends Controller{
	//render index page
	public void index()
	{
		renderFreeMarker("index.html");
	}
	//search function
	public void dosearch()
	{
		//define parameter
		String s_type;
		String s_content;
		
		//get parameter from front side
		s_type=getPara("searchtype");
		s_content=getPara("searchbox");
		System.out.println(s_type);
		System.out.println(s_content);
		
		
		//sql find jobs by uni_id;
		String sql_jobs_uni="select * from jobs where uni_id = ? order by id asc";	
		//sql find jobs by job_type
		String sql_jobs_type="select * from jobs where job_type = ? order by id asc";		
		//sql find jobs by location
		String sql_jobs_location="select * from jobs where location = ? order by id asc";
		//sql find jobs by main_sub_id
		String sql_jobs_sub="select * from jobs where main_sub_id = ? order by id asc";
		
		if("university".equals(s_type))
		{
			System.out.println("uni");
			long uni_id=getuni_id(s_content);
			int a=(int) uni_id;
			System.out.println(uni_id);
			setAttr("universitylist",Jobs.dao.find(sql_jobs_uni,a));
			renderFreeMarker("/index/universities.html");
			
		}
		if("subject".equals(s_type))
		{
			System.out.println("sub");
			long sub_id;
			sub_id=getsub_id(s_content);
			int a= (int) sub_id;
			setAttr("universitylist",Jobs.dao.find(sql_jobs_sub,a));
			renderFreeMarker("/index/subjects.html");
			
		}
		if("location".equals(s_type))
		{
			System.out.println("loc");
			setAttr("universitylist",Jobs.dao.find(sql_jobs_location,s_content));
			renderFreeMarker("/index/locations.html");	
		}
		if("job_type".equals(s_type))
		{
			System.out.println("typ");
			setAttr("universitylist",Jobs.dao.find(sql_jobs_type,s_content));
			renderFreeMarker("/index/jobtypes.html");	
		}
		
	}
	
	//find uni_id
	private long getuni_id(String uni_name)
	{
		University uni;
		long uni_id;
		String name= uni_name;
		//sql find uni_id
		String sql="select id from university where uni_name = ?";
		uni=University.dao.findFirst(sql, name);
		uni_id=uni.getLong("id");
		return uni_id;	
	}
	
	//find main_sub_id
	private long getsub_id(String sub_name)
	{
		Subject sub;
		long sub_id;
		String name= sub_name;
		//sql find main_sub_id
	    String sql="select id from subject where main_sub = ?";
		sub=Subject.dao.findFirst(sql,name);
		sub_id=sub.getLong("id");
		return sub_id;
	}
	//find jobs by uni_id or main_sub_id
	private List<Jobs> getjobsbyid(int a, String b)
	{
		int id=a;
		String sql=b;
		List<Jobs> jobs;
		jobs=Jobs.dao.find(sql,id);
		return jobs;
	}
	//find jobs by location or job_type
	private List<Jobs> getjobsbycontent(String a, String b)
	{	
		String content=a;
		String sql=b;
		List<Jobs> jobs;
		jobs=Jobs.dao.find(sql,content);
		return jobs;
	}

}
