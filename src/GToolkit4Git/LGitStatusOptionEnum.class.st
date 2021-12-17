Class {
	#name : #LGitStatusOptionEnum,
	#superclass : #LGitExternalEnumerationUInt32,
	#category : #'GToolkit4Git-FFI-Enums'
}

{ #category : #accessing }
LGitStatusOptionEnum class >> git_status_opt_exclude_submodules [
	^ self basicNew
		value: 8;
		yourself
]

{ #category : #accessing }
LGitStatusOptionEnum class >> git_status_opt_include_ignored [
	^ self basicNew
		value: 2;
		yourself
]

{ #category : #accessing }
LGitStatusOptionEnum class >> git_status_opt_include_unmodified [
	^ self basicNew
		value: 4;
		yourself
]

{ #category : #accessing }
LGitStatusOptionEnum class >> git_status_opt_include_untracked [
	^ self basicNew
		value: 1;
		yourself
]

{ #category : #accessing }
LGitStatusOptionEnum class >> git_status_opt_recurse_untracked_dirs [
	^ self basicNew
		value: 16;
		yourself
]

{ #category : #accessing }
LGitStatusOptionEnum >> enumDecl [
 ^ #(
	GIT_STATUS_OPT_INCLUDE_UNTRACKED 1

	GIT_STATUS_OPT_INCLUDE_IGNORED 2

	GIT_STATUS_OPT_INCLUDE_UNMODIFIED 4

	GIT_STATUS_OPT_EXCLUDE_SUBMODULES 8

	GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS 16

	GIT_STATUS_OPT_DISABLE_PATHSPEC_MATCH 32

	GIT_STATUS_OPT_RECURSE_IGNORED_DIRS 64

	GIT_STATUS_OPT_RENAMES_HEAD_TO_INDEX 128

	GIT_STATUS_OPT_RENAMES_INDEX_TO_WORKDIR 256

	GIT_STATUS_OPT_SORT_CASE_SENSITIVELY 512

	GIT_STATUS_OPT_SORT_CASE_INSENSITIVELY 1024

	GIT_STATUS_OPT_RENAMES_FROM_REWRITES 2048

	GIT_STATUS_OPT_NO_REFRESH 4096

	GIT_STATUS_OPT_UPDATE_INDEX 8192

	GIT_STATUS_OPT_INCLUDE_UNREADABLE 16384

	GIT_STATUS_OPT_INCLUDE_UNREADABLE_AS_UNTRACKED 32768
 )
]

{ #category : #accessing }
LGitStatusOptionEnum >> from: anInt [
	^ self class basicNew
		value: anInt;
		yourself
]

{ #category : #accessing }
LGitStatusOptionEnum >> | aStatusOptionEnum [
	^ self from: (self value | aStatusOptionEnum value)
]
