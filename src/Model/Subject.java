package Model;
import java.util.Map;
import com.jfinal.plugin.activerecord.Model;
public class Subject extends Model<Subject>
{
private static final long serialVersionUID=1L;
public static Subject dao =new Subject();
public Map<String,Object>getAttrs()
{
	return super.getAttrs();
}
}