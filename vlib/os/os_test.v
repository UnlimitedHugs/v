import os

const (
	// tfolder will contain all the temporary files/subfolders made by
	// the different tests. It would be removed in testsuite_end(), so
	// individual os tests do not need to clean up after themselves.
	tfolder = os.join_path( os.temp_dir(), 'v', 'tests', 'os_test')
)

fn testsuite_begin() {
	eprintln('testsuite_begin, tfolder = $tfolder')
	os.rmdir_all( tfolder )
	assert !os.is_dir( tfolder )
	os.mkdir_all( tfolder )
	os.chdir( tfolder )
	assert os.is_dir( tfolder )
}

fn testsuite_end() {
	os.chdir( os.wd_at_startup )
	os.rmdir_all( tfolder )
	assert !os.is_dir( tfolder )
}

fn test_open_file() {
	filename := './test1.txt'
	hello := 'hello world!'
	os.open_file(filename, 'r+', 0o666) or {
		assert err == 'No such file or directory'
	}
	mut file := os.open_file(filename, 'w+', 0o666) or {
		panic(err)
	}
	file.write(hello)
	file.close()
	assert hello.len == os.file_size(filename)
	read_hello := os.read_file(filename) or {
		panic('error reading file $filename')
	}
	assert hello == read_hello
	os.rm(filename)
}

fn test_create_file() {
	filename := './test1.txt'
	hello := 'hello world!'
	mut f := os.create(filename) or {
		panic(err)
	}
	f.write(hello)
	f.close()
	assert hello.len == os.file_size(filename)
	os.rm(filename)
}

fn test_write_and_read_string_to_file() {
	filename := './test1.txt'
	hello := 'hello world!'
	os.write_file(filename, hello)
	assert hello.len == os.file_size(filename)
	read_hello := os.read_file(filename) or {
		panic('error reading file $filename')
	}
	assert hello == read_hello
	os.rm(filename)
}

// test_write_and_read_bytes checks for regressions made in the functions
// read_bytes, read_bytes_at and write_bytes.
/*
fn test_write_and_read_bytes() {
        file_name :=  './byte_reader_writer.tst'
        payload   :=  [`I`, `D`, `D`, `Q`, `D`]

        mut file_write := os.create(os.real_path(file_name)) or {
                eprintln('failed to create file $file_name')
                return
        }

        // We use the standard write_bytes function to write the payload and
        // compare the length of the array with the file size (have to match).
        file_write.write_bytes(payload.data, 5)

        file_write.close()

        assert payload.len == os.file_size(file_name)

        mut file_read := os.open(os.real_path(file_name)) or {
          eprintln('failed to open file $file_name')
          return
        }

        // We only need to test read_bytes because this function calls
        // read_bytes_at with second parameter zeroed (size, 0).
        red_bytes := file_read.read_bytes(5)

        file_read.close()

        assert red_bytes.str() == payload.str()

        // We finally delete the test file.
        os.rm(file_name)
}
*/


fn test_create_and_delete_folder() {
	folder := './test1'
	os.mkdir(folder) or {
		panic(err)
	}
	assert os.is_dir(folder)
	folder_contents := os.ls(folder) or {
		panic(err)
	}
	assert folder_contents.len == 0
	os.rmdir(folder)
	folder_exists := os.is_dir(folder)
	assert folder_exists == false
}

fn walk_callback(file string) {
	if file == '.' || file == '..' {
		return
	}
	assert file == 'test_walk' + os.path_separator + 'test1'
}

fn test_walk() {
	folder := 'test_walk'
	os.mkdir(folder) or {
		panic(err)
	}
	file1 := folder + os.path_separator + 'test1'
	os.write_file(file1, 'test-1')
	os.walk(folder, walk_callback)
	os.rm(file1)
	os.rmdir(folder)
}

fn test_cp() {
	old_file_name := 'cp_example.txt'
	new_file_name := 'cp_new_example.txt'
	os.write_file(old_file_name, 'Test data 1 2 3, V is awesome #$%^[]!~⭐')
	os.cp(old_file_name, new_file_name) or {
		panic('$err: errcode: $errcode')
	}
	old_file := os.read_file(old_file_name) or {
		panic(err)
	}
	new_file := os.read_file(new_file_name) or {
		panic(err)
	}
	assert old_file == new_file
	os.rm(old_file_name)
	os.rm(new_file_name)
}

fn test_cp_r() {
	// fileX -> dir/fileX
	// NB: clean up of the files happens inside the cleanup_leftovers function
	os.write_file('ex1.txt', 'wow!')
	os.mkdir('ex') or {
		panic(err)
	}
	os.cp_all('ex1.txt', 'ex', false) or {
		panic(err)
	}
	old := os.read_file('ex1.txt') or {
		panic(err)
	}
	new := os.read_file('ex/ex1.txt') or {
		panic(err)
	}
	assert old == new
	os.mkdir('ex/ex2') or {
		panic(err)
	}
	os.write_file('ex2.txt', 'great!')
	os.cp_all('ex2.txt', 'ex/ex2', false) or {
		panic(err)
	}
	old2 := os.read_file('ex2.txt') or {
		panic(err)
	}
	new2 := os.read_file('ex/ex2/ex2.txt') or {
		panic(err)
	}
	assert old2 == new2
	// recurring on dir -> local dir
	os.cp_all('ex', './', true) or {
		panic(err)
	}
}

fn test_tmpdir() {
	t := os.temp_dir()
	assert t.len > 0
	assert os.is_dir(t)
	tfile := t + os.path_separator + 'tmpfile.txt'
	os.rm(tfile) // just in case
	tfile_content := 'this is a temporary file'
	os.write_file(tfile, tfile_content)
	tfile_content_read := os.read_file(tfile) or {
		panic(err)
	}
	assert tfile_content_read == tfile_content
	os.rm(tfile)
}

fn test_make_symlink_check_is_link_and_remove_symlink() {
	$if windows {
		// TODO
		assert true
		return
	}
	folder := 'tfolder'
	symlink := 'tsymlink'
	os.rm(symlink)
	os.rm(folder)
	os.mkdir(folder) or {
		panic(err)
	}
	folder_contents := os.ls(folder) or {
		panic(err)
	}
	assert folder_contents.len == 0
	os.system('ln -s $folder $symlink')
	assert os.is_link(symlink) == true
	os.rm(symlink)
	os.rm(folder)
	folder_exists := os.is_dir(folder)
	assert folder_exists == false
	symlink_exists := os.is_link(symlink)
	assert symlink_exists == false
}

// fn test_fork() {
// pid := os.fork()
// if pid == 0 {
// println('Child')
// }
// else {
// println('Parent')
// }
// }
// fn test_wait() {
// pid := os.fork()
// if pid == 0 {
// println('Child')
// exit(0)
// }
// else {
// cpid := os.wait()
// println('Parent')
// println(cpid)
// }
// }
fn test_symlink() {
	$if windows {
		return
	}
	os.mkdir('symlink') or {
		panic(err)
	}
	os.symlink('symlink', 'symlink2') or {
		panic(err)
	}
	assert os.exists('symlink2')
	// cleanup
	os.rm('symlink')
	os.rm('symlink2')
}

fn test_is_executable_writable_readable() {
	file_name := 'rwxfile.exe'
	mut f := os.create(file_name) or {
		eprintln('failed to create file $file_name')
		return
	}
	f.close()
	$if !windows {
		os.chmod(file_name, 0o600) // mark as readable && writable, but NOT executable
		assert os.is_writable(file_name)
		assert os.is_readable(file_name)
		assert !os.is_executable(file_name)
		os.chmod(file_name, 0o700) // mark as executable too
		assert os.is_executable(file_name)
	} $else {
		assert os.is_writable(file_name)
		assert os.is_readable(file_name)
		assert os.is_executable(file_name)
	}
	// We finally delete the test file.
	os.rm(file_name)
}

fn test_ext() {
	assert os.ext('file.v') == '.v'
	assert os.ext('file') == ''
}

fn test_is_abs() {
	assert os.is_abs_path('/home/user') == true
	assert os.is_abs_path('v/vlib') == false
	$if windows {
		assert os.is_abs_path('C:\\Windows\\') == true
	}
}

fn test_join() {
	$if windows {
		assert os.join_path('v','vlib','os') == 'v\\vlib\\os'
	} $else {
		assert os.join_path('v','vlib','os') == 'v/vlib/os'
	}
}

fn test_dir() {
	$if windows {
		assert os.dir('C:\\a\\b\\c') == 'C:\\a\\b'
	} $else {
		assert os.dir('/var/tmp/foo') == '/var/tmp'
	}
	assert os.dir('os') == '.'
}

fn test_basedir() {
	$if windows {
		assert os.base_dir('v\\vlib\\os') == 'v\\vlib'
	} $else {
		assert os.base_dir('v/vlib/os') == 'v/vlib'
	}
	assert os.base_dir('filename') == 'filename'
}
