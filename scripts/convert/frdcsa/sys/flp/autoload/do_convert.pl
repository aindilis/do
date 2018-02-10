loadDoConvert :-
	DoConvertQLFFilename = '/var/lib/myfrdcsa/codebases/minor/do-convert/prolog/generate-qlf-helper.qlf',
	exist_file(DoConvertQLFFilename),
	consult(DoConvertQLFFilename).
