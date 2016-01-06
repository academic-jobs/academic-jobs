package Model;
import java.util.Map;
import com.jfinal.plugin.activerecord.Model;
public class University extends Model<University>
{
private static final long serialVersionUID=1L;
public static University dao =new University();
public Map<String,Object>getAttrs()
{
	return super.getAttrs();
}
}
