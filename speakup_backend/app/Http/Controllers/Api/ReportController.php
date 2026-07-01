<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Contracts\ReportRepositoryInterface;
use App\Services\ReportService;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    protected $reportRepo;
    protected $reportService;

    public function __construct(ReportRepositoryInterface $reportRepo, ReportService $reportService)
    {
        $this->reportRepo = $reportRepo;
        $this->reportService = $reportService;
    }

    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->hasRole('siswa')) {
            $reports = $this->reportRepo->getByReporter($user->id, $request->all());
        } else {
            $reports = $this->reportRepo->getAll($request->all());
        }

        return response()->json([
            'success' => true,
            'message' => 'Daftar laporan',
            'data' => $reports
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'category' => 'nullable|string',
            'incident_location' => 'nullable|string',
            'incident_date' => 'nullable|string',
            'is_anonymous' => 'boolean',
            'participants' => 'nullable|array',
            'participants.*.role' => 'required|string|in:korban,terlapor,saksi',
            'participants.*.name' => 'nullable|string',
            'participants.*.class_name' => 'nullable|string',
            'participants.*.notes' => 'nullable|string',
            'evidences' => 'nullable|array',
        ]);

        $report = $this->reportService->createReport($request->all(), $request->user());

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil dibuat',
            'data' => $report
        ], 201);
    }

    public function show($id, Request $request)
    {
        $report = $this->reportRepo->getById($id);

        if ($request->user()->hasRole('siswa') && $report->reporter_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $report->load(['participants', 'statusHistories', 'validations.validator', 'mediations.mediator', 'followUps.executor']);

        return response()->json([
            'success' => true,
            'message' => 'Detail laporan',
            'data' => $report
        ]);
    }

    public function updateStatus($id, Request $request)
    {
        $request->validate([
            'status' => 'required|string|in:draft,submitted,waiting_validation,valid,processing,mediation,follow_up,completed,rejected',
            'notes' => 'nullable|string',
        ]);

        $user = $request->user();

        if (!$user->hasRole('guru_bk') && !$user->hasRole('admin')) {
            return response()->json(['success' => false, 'message' => 'Unauthorized access'], 403);
        }

        $report = $this->reportService->updateStatus($id, $request->status, $user->id, $request->notes);

        return response()->json([
            'success' => true,
            'message' => 'Status laporan berhasil diperbarui',
            'data' => $report
        ]);
    }
}
