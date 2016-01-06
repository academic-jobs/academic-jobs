package Model;
import java.util.Map;
import com.jfinal.plugin.activerecord.Model;
public class Jobs extends Model<Jobs>
{
private static final long serialVersionUID=1L;
public static Jobs dao =new Jobs();
public Map<String,Object>getAttrs()
{
	return super.getAttrs();
}
}