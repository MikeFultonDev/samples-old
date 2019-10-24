class genconv {
	public static void main(String args[]) {
		String ebcdicCodePage = "IBM-1047";

		StringBuffer sb = new StringBuffer();
		for (char i=0; i<256; ++i) {
			sb.append(i);
		}
		String s = new String(sb);
		byte[] ebcdic = null;
		try {
			ebcdic = s.getBytes(ebcdicCodePage);
		} catch (java.io.UnsupportedEncodingException uee) {
			System.err.println("Unable to convert to code page " + ebcdicCodePage);
			System.exit(16);
		}

		byte[] ascii = new byte[256];
		System.out.print("char ebcdic[] = {");
		for (char i=0; i<256; ++i) {
			int val = ebcdic[i];
			if (val < 0) {
				val += 256;
			}
			ascii[val] = (byte) i;
			if (i % 16 == 0) {
				System.out.print("\n\t");
			}
			System.out.print(val);
			System.out.print(",\t");
		}
		System.out.println("\n};");
		System.out.print("char ascii[] = {");
		for (char i=0; i<256; ++i) {
			int val = ascii[i];
			if (val < 0) {
				val += 256;
			}
			if (i % 16 == 0) {
				System.out.print("\n\t");
			}
			System.out.print(val);
			System.out.print(",\t");
		}	
		System.out.println("\n};");
	}
}
