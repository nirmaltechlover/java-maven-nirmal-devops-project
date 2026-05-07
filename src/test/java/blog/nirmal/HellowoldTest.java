package blog.nirmal;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class HellowoldTest {

    @Test
    public void testMessage() {
        assertEquals("Hello DevOps World!", Hellowold.getMessage());
    }
}
