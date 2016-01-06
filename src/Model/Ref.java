package Model;
import java.util.Map;
import com.jfinal.plugin.activerecord.Model;
public class Ref extends Model<Ref>
{
private static final long serialVersionUID=1L;
public static Ref dao =new Ref();
public Map<String,Object>getAttrs()
{
	return super.getAttrs();
}
}