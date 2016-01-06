package Demo;





import Controller.analysisController;
import Controller.detailController;
import Controller.indexController;
import Model.Department;
import Model.Jobs;
import Model.Ref;
import Model.Ref_dept;
import Model.Subject;
import Model.Toptendept;
import Model.Toptenuni;
import Model.University;


import com.jfinal.config.*;
import com.jfinal.core.Const;
import com.jfinal.plugin.activerecord.ActiveRecordPlugin;
import com.jfinal.plugin.druid.DruidPlugin;
import com.jfinal.render.ViewType;


public class DemoConfig extends JFinalConfig
{

	@Override
	public void configConstant(Constants me) {
		// TODO Auto-generated method stub
		me.setDevMode(true);
		me.setMaxPostSize(10000*Const.DEFAULT_MAX_POST_SIZE);
	}

	@Override
	public void configRoute(Routes me) {
		// TODO Auto-generated method stub
		me.add("/index", indexController.class);
		me.add("/details",detailController.class);
		me.add("/analysis",analysisController.class);
		
	}

	@Override
	public void configPlugin(Plugins me) {
		// TODO Auto-generated method stub
		
		
		String decPassWord="123456bB";
		String decUser ="root";
		String jdbcUrl="jdbc:mysql://localhost:3306/academic?characterEncoding=utf8";
		DruidPlugin druid =new DruidPlugin(jdbcUrl,decUser,decPassWord);
		me.add(druid);
		ActiveRecordPlugin arp= new ActiveRecordPlugin(druid);
		me.add(arp);
		
		//creating relationship between Table and Model
		arp.addMapping("jobs","id",Jobs.class);
		arp.addMapping("university","id",University.class);
		arp.addMapping("ref","id",Ref.class);
		arp.addMapping("subject","id",Subject.class);
		arp.addMapping("ref_dept","id",Ref_dept.class);
		arp.addMapping("department","id",Department.class);
		arp.addMapping("toptenuni","id",Toptenuni.class);
		arp.addMapping("toptendept","id",Toptendept.class);
	}

	@Override
	public void configInterceptor(Interceptors me) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void configHandler(Handlers me) {
		// TODO Auto-generated method stub
	}

	
}
