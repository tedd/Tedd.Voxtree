# D1 preparation failure

The first D1 preparation exited with KeyError: baseline before creating the D1
directory, catalog, controller, grants or plans. The archived serializer omits
null fields; the validator incorrectly required the key to exist. The failed
outer driver SHA-256 was
1DCE494310C933A140A91CE1D564291B1A6B3B4539B3E4A0F93BEA5F7765584B.

The failed execution was terminal and D1's directory was verified absent.
Validation now interprets an absent baseline as null without changing inputs,
budgets or the prospective protocol. No measurement submission occurred and no
failed-session replacement or old-family resume is performed. Retain this setup
failure separately from any actual lifecycle/confirmation failure.
