Class {
	#name : #LGitStatusOptionEnum,
	#superclass : #LGitExternalEnumerationUInt32,
	#category : #'GToolkit4Git-FFI-Enums'
}

{ #category : #accessing }
LGitStatusOptionEnum class >> enumDecl [
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

{ #category : #'instance creation' }
LGitStatusOptionEnum class >> from: anInt [
	^ self basicNew
		value: anInt;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_disable_pathspec_match [
	^ self basicNew
		value: 32;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_exclude_submodules [
	^ self basicNew
		value: 8;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_include_ignored [
	^ self basicNew
		value: 2;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_include_unmodified [
	^ self basicNew
		value: 4;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_include_unreadable [
	^ self basicNew
		value: 16384;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_include_unreadable_as_untracked [
	^ self basicNew
		value: 32768;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_include_untracked [
	^ self basicNew
		value: 1;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_no_refresh [
	^ self basicNew
		value: 4096;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_recurse_ignored_dirs [
	^ self basicNew
		value: 64;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_recurse_untracked_dirs [
	^ self basicNew
		value: 16;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_renames_from_rewrites [
	^ self basicNew
		value: 2048;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_renames_head_to_index [
	^ self basicNew
		value: 128;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_renames_index_to_workdir [
	^ self basicNew
		value: 256;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_sort_case_insensitively [
	^ self basicNew
		value: 1024;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_sort_case_sensitively [
	^ self basicNew
		value: 512;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusOptionEnum class >> git_status_opt_update_index [
	^ self basicNew
		value: 8192;
		yourself
]
