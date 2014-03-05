class PatchFromStringsTest < Rugged::SandboxedTestCase
  def test_from_strings_no_args
    patch = Rugged::Patch.from_strings()
    assert_equal 0, patch.size
    assert_equal "", patch.to_s
  end

  def test_from_strings_create_file
    patch = Rugged::Patch.from_strings(nil, "added\n")
    assert_equal 1, patch.size
    assert_equal <<-EOS, patch.to_s
diff --git a/file b/file
new file mode 100644
index 0000000..d5f7fc3
--- /dev/null
+++ b/file
@@ -0,0 +1 @@
+added
EOS
  end

  def test_from_strings_delete_file
    patch = Rugged::Patch.from_strings("deleted\n", nil)
    assert_equal 1, patch.size
    assert_equal <<-EOS, patch.to_s
diff --git a/file b/file
deleted file mode 100644
index 71779d2..0000000
--- a/file
+++ /dev/null
@@ -1 +0,0 @@
-deleted
EOS
  end

  def test_from_strings_without_paths
    patch = Rugged::Patch.from_strings("deleted\n", "added\n")
    assert_equal 1, patch.size
    assert_equal <<-EOS, patch.to_s
diff --git a/file b/file
index 71779d2..d5f7fc3 100644
--- a/file
+++ b/file
@@ -1 +1 @@
-deleted
+added
EOS
  end

  def test_from_strings_with_custom_paths
    patch = Rugged::Patch.from_strings("deleted\n", "added\n", old_path: "old", new_path: "new")
    assert_equal 1, patch.size
    assert_equal <<-EOS, patch.to_s
diff --git a/old b/new
index 71779d2..d5f7fc3 100644
--- a/old
+++ b/new
@@ -1 +1 @@
-deleted
+added
EOS
  end
end

  def test_delta_status_char
    repo = sandbox_init("attr")
    diff = repo.diff("605812a", "370fe9ec22", :context_lines => 1, :interhunk_lines => 1)

    deltas = diff.deltas

    assert_equal :D, deltas[0].status_char 
    assert_equal :A, deltas[1].status_char 
    assert_equal :A, deltas[2].status_char 
    assert_equal :M, deltas[3].status_char 
    assert_equal :M, deltas[4].status_char 
  end

  def test_each_line_patch
    repo = sandbox_init("diff")

    a = repo.lookup("d70d245ed97ed2aa596dd1af6536e4bfdb047b69")
    b = repo.lookup("7a9e0b02e63179929fed24f0a3e0f19168114d10")

    diff = a.tree.diff(b.tree)

    lines = diff.each_line.to_a
    assert_equal 63, lines.size

    assert_equal(:file_header, lines[0].line_origin)
    assert_equal("diff --git a/another.txt b/another.txt\nindex 3e5bcba..546c735 100644\n--- a/another.txt\n+++ b/another.txt\n", lines[0].content)
    assert_equal(0, lines[0].content_offset)
    assert_equal(-1, lines[0].old_lineno)
    assert_equal(-1, lines[0].new_lineno)

    assert_equal(:hunk_header, lines[1].line_origin)
    assert_equal("@@ -1,5 +1,5 @@\n", lines[1].content)
    assert_equal(0, lines[1].content_offset)
    assert_equal(-1, lines[1].old_lineno)
    assert_equal(-1, lines[1].new_lineno)

    assert_equal(:context, lines[2].line_origin)
    assert_equal("Git is fast. With Git, nearly all operations are performed locally, giving\n", lines[2].content)
    assert_equal(nil, lines[2].content_offset)
    assert_equal(1, lines[2].old_lineno)
    assert_equal(1, lines[2].new_lineno)

    assert_equal(:deletion, lines[3].line_origin)
    assert_equal("it a huge speed advantage on centralized systems that constantly have to\n", lines[3].content)
    assert_equal(75, lines[3].content_offset)
    assert_equal(2, lines[3].old_lineno)
    assert_equal(-1, lines[3].new_lineno)

    assert_equal(:addition, lines[4].line_origin)
    assert_equal("it an huge speed advantage on centralized systems that constantly have to\n", lines[4].content)
    assert_equal(75, lines[4].content_offset)
    assert_equal(-1, lines[4].old_lineno)
    assert_equal(2, lines[4].new_lineno)
  end

  def test_each_line_patch_header
    repo = sandbox_init("diff")

    a = repo.lookup("d70d245ed97ed2aa596dd1af6536e4bfdb047b69")
    b = repo.lookup("7a9e0b02e63179929fed24f0a3e0f19168114d10")

    diff = a.tree.diff(b.tree)

    lines = diff.each_line(:patch_header).to_a
    assert_equal 2, lines.size

    assert_equal(:file_header, lines[0].line_origin)
    assert_equal("diff --git a/another.txt b/another.txt\nindex 3e5bcba..546c735 100644\n--- a/another.txt\n+++ b/another.txt\n", lines[0].content)
    assert_equal(0, lines[0].content_offset)
    assert_equal(-1, lines[0].old_lineno)
    assert_equal(-1, lines[0].new_lineno)

    assert_equal(:file_header, lines[1].line_origin)
    assert_equal("diff --git a/readme.txt b/readme.txt\nindex 7b808f7..29ab705 100644\n--- a/readme.txt\n+++ b/readme.txt\n", lines[1].content)
    assert_equal(0, lines[1].content_offset)
    assert_equal(-1, lines[1].old_lineno)
    assert_equal(-1, lines[1].new_lineno)
  end

  def test_each_line_raw
    repo = sandbox_init("diff")

    a = repo.lookup("d70d245ed97ed2aa596dd1af6536e4bfdb047b69")
    b = repo.lookup("7a9e0b02e63179929fed24f0a3e0f19168114d10")

    diff = a.tree.diff(b.tree)

    lines = diff.each_line(:raw).to_a
    assert_equal 2, lines.size

    assert_equal(:file_header, lines[0].line_origin)
    assert_equal(":100644 100644 3e5bcba... 546c735... M\tanother.txt\n", lines[0].content)
    assert_equal(0, lines[0].content_offset)
    assert_equal(-1, lines[0].old_lineno)
    assert_equal(-1, lines[0].new_lineno)

    assert_equal(:file_header, lines[1].line_origin)
    assert_equal(":100644 100644 7b808f7... 29ab705... M\treadme.txt\n", lines[1].content)
    assert_equal(0, lines[1].content_offset)
    assert_equal(-1, lines[1].old_lineno)
    assert_equal(-1, lines[1].new_lineno)
  end

  def test_each_line_name_only
    repo = sandbox_init("diff")

    a = repo.lookup("d70d245ed97ed2aa596dd1af6536e4bfdb047b69")
    b = repo.lookup("7a9e0b02e63179929fed24f0a3e0f19168114d10")

    diff = a.tree.diff(b.tree)

    lines = diff.each_line(:name_only).to_a
    assert_equal 2, lines.size

    assert_equal(:file_header, lines[0].line_origin)
    assert_equal("another.txt\n", lines[0].content)
    assert_equal(0, lines[0].content_offset)
    assert_equal(-1, lines[0].old_lineno)
    assert_equal(-1, lines[0].new_lineno)

    assert_equal(:file_header, lines[1].line_origin)
    assert_equal("readme.txt\n", lines[1].content)
    assert_equal(0, lines[1].content_offset)
    assert_equal(-1, lines[1].old_lineno)
    assert_equal(-1, lines[1].new_lineno)
  end

  def test_each_line_name_status
    repo = sandbox_init("diff")

    a = repo.lookup("d70d245ed97ed2aa596dd1af6536e4bfdb047b69")
    b = repo.lookup("7a9e0b02e63179929fed24f0a3e0f19168114d10")

    diff = a.tree.diff(b.tree)

    lines = diff.each_line(:name_status).to_a
    assert_equal 2, lines.size

    assert_equal(:file_header, lines[0].line_origin)
    assert_equal("M\tanother.txt\n", lines[0].content)
    assert_equal(0, lines[0].content_offset)
    assert_equal(-1, lines[0].old_lineno)
    assert_equal(-1, lines[0].new_lineno)

    assert_equal(:file_header, lines[1].line_origin)
    assert_equal("M\treadme.txt\n", lines[1].content)
    assert_equal(0, lines[1].content_offset)
    assert_equal(-1, lines[1].old_lineno)
    assert_equal(-1, lines[1].new_lineno)
  end

  def test_each_line_unknown_format_raises_error
    repo = sandbox_init("diff")

    a = repo.lookup("d70d245ed97ed2aa596dd1af6536e4bfdb047b69")
    b = repo.lookup("7a9e0b02e63179929fed24f0a3e0f19168114d10")

    diff = a.tree.diff(b.tree)

    assert_raises ArgumentError do
      diff.each_line(:foobar).to_a
    end
  end
