package Controller;

import java.util.List;

import Model.Jobs;
import Model.Ref;
import Model.Ref_dept;
import Model.Subject;
import Model.Toptendept;
import Model.Toptenuni;
import Model.University;

import com.jfinal.core.Controller;

public class analysisController extends Controller{
	float finalscore=0;
	float deptscore=0;
	float decuni=0;
	float decdept=0;
	public void index()
	{	
	}	
	

	public void southampton()
	{
		String sql0="select * from toptenuni order by stars desc limit 10";
		List<Toptenuni> top_uni=Toptenuni.dao.find(sql0);
		for(int i=0;i<10;i++)
		{
			int uni_id;	
			uni_id=top_uni.get(i).getInt("uni_id");
			String uniname=getuni_name(uni_id);
			List<Jobs> jobs=countjobs(uni_id);
			top_uni.get(i).put("rank", i+1);
			top_uni.get(i).put("uni_name", uniname);
		}
		String sql1="select * from toptendept order by stars desc limit 10";
		List<Toptendept> top_dept=Toptendept.dao.find(sql1);
		for(int i=0;i<10;i++)
		{
			int id;	
			String deptname;
			id=top_dept.get(i).getInt("ref_dept_id");
			deptname=Ref_dept.dao.findById(id).getStr("ref_dept_name");
			top_dept.get(i).put("rank", i+1);
			top_dept.get(i).put("dept_name", deptname);
		}
		
		setAttr("deptlist",top_dept);
		setAttr("objectlist",top_uni);
		renderFreeMarker("/analysis/southampton.html");
	}
	public void aston()
	{
		String sql0="select * from toptenuni order by stars desc limit 10";
		List<Toptenuni> top_uni=Toptenuni.dao.find(sql0);
		for(int i=0;i<10;i++)
		{
			int uni_id;	
			uni_id=top_uni.get(i).getInt("uni_id");
			String uniname=getuni_name(uni_id);
			List<Jobs> jobs=countjobs(uni_id);
			top_uni.get(i).put("rank", i+1);
			top_uni.get(i).put("uni_name", uniname);
		}
		String sql1="select * from toptendept order by stars desc limit 10";
		List<Toptendept> top_dept=Toptendept.dao.find(sql1);
		for(int i=0;i<10;i++)
		{
			int id;	
			String deptname;
			id=top_dept.get(i).getInt("ref_dept_id");
			deptname=Ref_dept.dao.findById(id).getStr("ref_dept_name");
			top_dept.get(i).put("rank", i+1);
			top_dept.get(i).put("dept_name", deptname);
		}
		
		setAttr("deptlist",top_dept);
		setAttr("objectlist",top_uni);
		renderFreeMarker("/analysis/aston.html");
	}
	//sum all department stars for each university
	private float [] sumunistar(int l)
	{
		int uni_id;
		uni_id=l;
		String sql_unistar="select * from ref where uni_id = ?";
		List<Ref> u=Ref.dao.find(sql_unistar,uni_id);
		System.out.println(u);
		float sumstar []={0,0,0,0,0};
		for(int i=0;i<u.size();i++)
		{
			float four=u.get(i).getFloat("fourstar");
			float three=u.get(i).getFloat("threestar");
			float two=u.get(i).getFloat("twostar");
			float one=u.get(i).getFloat("onestar");
			float zero=u.get(i).getFloat("unclassified");
			sumstar[0]=sumstar[0]+zero;
			sumstar[1]=sumstar[1]+one;
			sumstar[2]=sumstar[2]+two;
			sumstar[3]=sumstar[3]+three;
			sumstar[4]=sumstar[4]+four;		
		}
		return sumstar;
	}
	
	//sum all university stars for each department	
	private float [] sumdeptstar(int l)
	{
		int dept_id;
		dept_id=l;
		String sql_unistar="select * from ref where ref_dept_id = ?";
		List<Ref> u=Ref.dao.find(sql_unistar,dept_id);
		System.out.println(u);
		float sumstar []={0,0,0,0,0};
		for(int i=0;i<u.size();i++)
		{
			float four=u.get(i).getFloat("fourstar");
			float three=u.get(i).getFloat("threestar");
			float two=u.get(i).getFloat("twostar");
			float one=u.get(i).getFloat("onestar");
			float zero=u.get(i).getFloat("unclassified");
			sumstar[0]=sumstar[0]+zero;
			sumstar[1]=sumstar[1]+one;
			sumstar[2]=sumstar[2]+two;
			sumstar[3]=sumstar[3]+three;
			sumstar[4]=sumstar[4]+four;		
		}
		return sumstar;
	}
	
	/*
	 * top10 university
	 */
	private void toptenuniversity()
	{
		int i;
		System.out.println("1");
		String sql="select distinct uni_id from ref";
		
		List<Ref> x=Ref.dao.find(sql);
		System.out.println(x.get(1));
		System.out.println(x.size());
		for(i=0;i<x.size();i++)
		{
			System.out.println("============");
			long a=x.get(i).getLong("uni_id");
			int s= (int)a;
			String sql_uni="select * from ref where uni_id = ? order by id asc";
			List<Ref> r=Ref.dao.find(sql_uni,s);
			for(int m=0;m<r.size();m++)
			{		
				float result=r.get(m).getFloat("fourstar")*4+r.get(m).getFloat("threestar")*3+r.get(m).getFloat("twostar")*2+r.get(m).getFloat("onestar")*1;
				finalscore= finalscore+result;
			}
			for(int n=0;n<r.size();n++)
			{	
				float result=r.get(n).getFloat("fourstar")+r.get(n).getFloat("threestar")+r.get(n).getFloat("twostar")+r.get(n).getFloat("onestar");
				decuni= decuni+result;
			}
			
			finalscore=finalscore/decuni;
			System.out.println(finalscore);
			System.out.println(finalscore/decuni);
			new Toptenuni().set("uni_id", a).set("stars",finalscore).save();
			finalscore=0;
			decuni=0;
		}
		
	}
	
	/*
	 * top10 departments
	 */
	private void toptendepartment()
	{
		int i;
		String sql="select distinct ref_dept_id from ref";	
		List<Ref> x=Ref.dao.find(sql);
		System.out.println(x.get(1));
		System.out.println(x.size());
		for(i=0;i<x.size();i++)
		{
			System.out.println("============");
			long a=x.get(i).getLong("ref_dept_id");
			int s= (int)a;
			String sql_dept="select * from ref where ref_dept_id = ? order by id asc";
			List<Ref> r=Ref.dao.find(sql_dept,s);
			System.out.println(r);
			for(int m=0;m<r.size();m++)
			{	
				float result=r.get(m).getFloat("fourstar")*4+r.get(m).getFloat("threestar")*3+r.get(m).getFloat("twostar")*2+r.get(m).getFloat("onestar")*1;
				System.out.println(result);
				deptscore= deptscore+result;		
			}
			for(int n=0;n<r.size();n++)
			{	
				float result=r.get(n).getFloat("fourstar")+r.get(n).getFloat("threestar")+r.get(n).getFloat("twostar")+r.get(n).getFloat("onestar");
				System.out.println(result);
				decdept= decdept+result;
			}
			deptscore=deptscore/decdept;
			new Toptendept().set("ref_dept_id", a).set("stars",deptscore).save();
			deptscore=0;
			decdept=0;
		}
	}
	
	
	//count subjects for each university
 	private List<Jobs> countsub(int a)
 	{
 		int uni_id=a;
 		String sql="select distinct main_sub_id from jobs where uni_id = ? order by id asc";
 		List<Jobs> job=Jobs.dao.find(sql,uni_id);
 		System.out.println(job);
 		return job;
 	}
	
	//count locations for each job_type	
    private List<Jobs> countlocations(String a)
	{	
		String job_type=a;
		List<Jobs> job;
		String sql="select distinct location from jobs where job_type = ?";
		job=Jobs.dao.find(sql,job_type);
		return job;
	}
	
    //count  job_types for each university
	private List<Jobs> counttype(int a)
	{
		System.out.println("========");
		int uni_id=a;
		String sql="select distinct job_type from jobs where uni_id = ? order by id asc";
 		List<Jobs> job=Jobs.dao.find(sql,uni_id);
 		return job;
	}
	
	//count numbers of job of each university
	private List<Jobs> countjobs(int a)
	{
		int uni_id=a;	
		String sql="select id from jobs  where uni_id = ? order by id asc";
 		List<Jobs> job=Jobs.dao.find(sql,uni_id);
 		return job;
	}
	
	
	
	private String getsub(int a)
    {
   	 	int sub_id=a;
   	 	String sub;
   	 	sub=Subject.dao.findById(sub_id).getStr("main_sub");
   	 	return sub;
    }
	private String getuni_name(int a)
    {
		int uni_id=a;
		String uni_name;
		uni_name=University.dao.findById(uni_id).getStr("uni_name");
		return uni_name;
    }
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
	
}
