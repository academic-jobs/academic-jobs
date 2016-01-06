package Model;
import java.util.Map;
import com.jfinal.plugin.activerecord.Model;
public class Department extends Model<Department>
{
private static final long serialVersionUID=1L;
public static Department dao =new Department();
public Map<String,Object>getAttrs()
{
	return super.getAttrs();
}
}