package register;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.Test;

import register.Registers;

public class RegistersTest {

	@Test
	public void generatesToString() {
		assertThat(new Registers(2, 3, 5, 8).toString()).isEqualTo("2, 3, 5, 8");
		assertThat(new Registers(2, 3, 5, 8).toString()).isEqualTo("2, 3, 5, 8");
	}
	
	@Test
	public void gets() {
		final Registers registers = new Registers(2, 3, 5, 8);
		assertThat(registers.get(2)).isEqualTo(5);
	}
}
