package Model;
import java.util.Map;
import com.jfinal.plugin.activerecord.Model;
public class Toptendept extends Model<Toptendept>
{
private static final long serialVersionUID=1L;
public static Toptendept dao =new Toptendept();
public Map<String,Object>getAttrs()
{
	return super.getAttrs();
}
}

