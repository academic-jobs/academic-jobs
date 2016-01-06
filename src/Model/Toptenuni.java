package Model;
import java.util.Map;
import com.jfinal.plugin.activerecord.Model;
public class Toptenuni extends Model<Toptenuni>
{
private static final long serialVersionUID=1L;
public static Toptenuni dao =new Toptenuni();
public Map<String,Object>getAttrs()
{
	return super.getAttrs();
}
}
